---
title: dubbo和zookeeper的关系
date: 2019-05-02 16:01:20
categories:
- dubbo
---

**转载前言：**网络上很多教程没有描述zookeeper和dubbo到底是什么关系、分别扮演了什么角色等信息，都是说一些似是而非的话，这里终于找到一篇文章，比较生动地描述了注册中心和微服务框架之间的关系，以及他们之间的合作分工。

下面附上我读完之后的理解：

> **dubbo**是一个远程调用服务的分布式框架，可以实现远程通讯、动态配置、地址路由等等功能。
> 比如在入门demo里的暴露服务，使得远程调用的协议可以使用dobbo协议(dubbo://x.x.x.x)或者其它协议，可以配置zookeeper集群地址，实现软负载均衡并配置均衡方式等。
> 在不搭配注册中心的时候，它也是可以实现服务端和调用端的通信的，这种方式是点对点通信的，所谓“没有中间商”。但是如果配置服务发布和调用端过多特别是集群的方式提供服务的时候，就会暴露许多的问题：增加节点需要修改配置文件、服务端机器宕机后不能被感知等。
>
> 它可以通过集成**注册中心**，来动态地治理服务发布和服务调用。相当于把服务注册和发布推送的功能分摊给了(zookeeper)注册中心。

原帖地址：<https://www.javazhiyin.com/28425.html#m>

## 介绍

微服务是最近比较火的概念，而微服务框架目前主流的有Dubbo和Spring Cloud，两者都是为了解决微服务遇到的各种问题而产生的，即遇到的问题是一样的，但是解决的策略却有所不同，所以这2个框架经常拿来比较。没用过Dubbo的小伙伴也不用担心，其实Dubbo还是比较简单的，看完本文你也能掌握一个大概，重要的不是代码，而是思想。

Dubbo实现服务调用是通过RPC的方式，即客户端和服务端共用一个接口(将接口打成一个jar包，在客户端和服务端引入这个jar包)，客户端面向接口写调用，服务端面向接口写实现，中间的网络通信交给框架去实现，想深入了解的看推荐阅读。原文链接有代码GitHub地址



## 使用入门

### **服务提供者**



定义服务接口



```java
public interface DemoService {
    String sayHello(String name);
}
```



在服务提供方实现接口



```java
public class DemoServiceImpl implements DemoService {
    @Override
    public String sayHello(String name) {
        return "Hello " + name;
    }
}
```



用 Spring 配置声明暴露服务

provider.xml（省略了beans标签的各种属性）



```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans>

    <!-- 当前项目在整个分布式架构里面的唯一名称，用于计算依赖关系 -->
    <dubbo:application name="helloworld-app"  />

    <!--dubbo这个服务所要暴露的服务地址所对应的注册中心，N/A为不使用注册中心-->
    <dubbo:registry address="N/A"/>

    <!--当前服务发布所依赖的协议；webserovice、Thrift、Hessain、http-->
    <dubbo:protocol name="dubbo" port="20880"/>

    <!--服务发布的配置，需要暴露的服务接口-->
    <dubbo:service interface="com.st.DemoService"
                   ref="demoService"/>

    <!--bean的定义-->
    <bean id="demoService" class="com.st.DemoServiceImpl"/>

</beans>
```



加载 Spring 配置



```java
public class Provider {

    public static void main(String[] args) throws Exception {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("provider.xml");
        context.start();
        System.in.read(); // 按任意键退出
    }
}
```



### **服务消费者**



consumer.xml



```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans>

    <!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
    <dubbo:application name="consumer-of-helloworld-app"/>

    <dubbo:registry address="N/A"/>

    <!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
    <dubbo:reference id="demoService" interface="com.st.DemoService"
                     url="dubbo://localhost:20880/com.st.DemoService"/>

</beans>
```



加载Spring配置，并调用远程服务



```java
public class Consumer {

    public static void main(String[] args) throws Exception {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("consumer.xml");
        context.start();
        // 获取远程服务代理
        DemoService demoService = (DemoService)context.getBean("demoService");
        // 执行远程方法
        String hello = demoService.sayHello("world");
        // Hello world
        System.out.println( hello );
    }
}
```



这就是典型的点对点的服务调用。当然我们为了高可用，可以在consumer.xml中配置多个服务提供者，并配置响应的负载均衡策略

配置多个服务调用者在comsumer.xml的<dubbo:reference>标签的url属性中加入多个地址，中间用分号隔开即可配置负载均衡策略在comsumer.xml的<dubbo:reference>标签中增加loadbalance属性即可，值可以为如下四种类型

1. RoundRobin LoadBalance，随机，按权重设置随机概率。
2. RoundRobin LoadBalance，轮询，按公约后的权重设置轮询比率。
3. LeastActive LoadBalance，最少活跃调用数，相同活跃数的随机，活跃数指调用前后计数差。
4. ConsistentHash LoadBalance，一致性 Hash，相同参数的请求总是发到同一提供者。



```xml
<dubbo:reference id="demoService" interface="com.st.DemoService"
                 url="dubbo://192.168.11.1:20880/com.st.DemoService;
                 dubbo://192.168.11.2:20880/com.st.DemoService;
                 dubbo://192.168.11.3:20880/com.st.DemoService"
                 loadbalance="roundrobin"/>
```



现在整体架构是如下图（假设服务消费者为订单服务，服务提供者为用户服务）：

![图解Dubbo和ZooKeeper是如何协同工作的？](https://www.javazhiyin.com/wp-content/uploads/2019/01/java4-1548405141.png)

这样会有什么问题呢？



1. 当服务提供者增加节点时，需要修改配置文件
2. 当其中一个服务提供者宕机时，服务消费者不能及时感知到，还会往宕机的服务发送请求



这个时候就得引入注册中心了



注册中心

Dubbo目前支持4种注册中心,（multicast zookeeper redis simple） 推荐使用Zookeeper注册中心，本文就讲一下用zookeeper实现服务注册和发现（敲黑板，又一种zookeeper的用处），大致流程如下



![图解Dubbo和ZooKeeper是如何协同工作的？](https://www.javazhiyin.com/wp-content/uploads/2019/01/java3-1548405141.png)

现在我们来看Dubbo官网对Dubbo的介绍图，有没有和我们上面画的很相似



![图解Dubbo和ZooKeeper是如何协同工作的？](https://www.javazhiyin.com/wp-content/uploads/2019/01/java0-1548405142.jpeg)



**节点角色说明**



| 节点      | 角色说明                               |
| --------- | -------------------------------------- |
| Provider  | 暴露服务的服务提供方                   |
| Consumer  | 调用远程服务的服务消费方               |
| Registry  | 服务注册与发现的注册中心               |
| Monitor   | 统计服务的调用次数和调用时间的监控中心 |
| Container | 服务运行容器                           |



**调用关系说明**



1. 服务容器负责启动（上面例子为Spring容器），加载，运行服务提供者。
2. 服务提供者在启动时，向注册中心注册自己提供的服务。
3. 服务消费者在启动时，向注册中心订阅自己所需的服务。
4. 注册中心返回服务提供者地址列表给消费者，如果有变更，注册中心将基于长连接推送变更数据给消费者。
5. 服务消费者，从提供者地址列表中，基于软负载均衡算法，选一台提供者进行调用，如果调用失败，再选另一台调用。
6. 服务消费者和提供者，在内存中累计调用次数和调用时间，定时每分钟发送一次统计数据到监控中心。



要使用注册中心，只需要**将provider.xml和consumer.xml更改为如下**



```xml
<!--<dubbo:registry address="N/A"/>-->
<dubbo:registry protocol="zookeeper" address="192.168.11.129:2181"/>
```



如果zookeeper是一个集群，则多个地址之间用逗号分隔即可



```xml
<dubbo:registry protocol="zookeeper" address="192.168.11.129:2181,192.168.11.137:2181,192.168.11.138:2181"/>
```



**把consumer.xml中配置的直连的方式去掉**



```xml
<!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
<!--<dubbo:reference id="demoService" interface="com.st.DemoService"-->
                 <!--url="dubbo://localhost:20880/com.st.DemoService"/>-->


<dubbo:reference id="demoService" interface="com.st.DemoService"/>
```



注册信息在zookeeper中如何保存？

启动上面服务后，我们观察zookeeper的根节点多了一个dubbo节点及其他，图示如下



![图解Dubbo和ZooKeeper是如何协同工作的？](https://www.javazhiyin.com/wp-content/uploads/2019/01/java7-1548405142.png)

最后一个节点中192.168.1.104是小编的内网地址，你可以任务和上面配置的localhost一个效果，大家可以想一下我为什么把最后一个节点标成绿色的。没错，最后一个节点是临时节点，而其他节点是持久节点，这样，当服务宕机时，这个节点就会自动消失，不再提供服务，服务消费者也不会再请求。如果部署多个DemoService，则providers下面会有好几个节点，一个节点保存一个DemoService的服务地址



其实一个zookeeper集群能被多个应用公用，如小编Storm集群和Dubbo配置的就是一个zookeeper集群，为什么呢？因为不同的框架会在zookeeper上建不同的节点，互不影响。如dubbo会创建一个/dubbo节点，storm会创建一个/storm节点，如图



![图解Dubbo和ZooKeeper是如何协同工作的？](https://www.javazhiyin.com/wp-content/uploads/2019/01/java7-1548405142-1.png)



------

### zookeeper相关介绍

[Zookeeper](http://zookeeper.apache.org/) 是 Apacahe Hadoop 的子项目，是一个树型的目录服务，支持变更推送，适合作为 Dubbo 服务的注册中心，工业强度较高，可用于生产环境，并推荐使用。

![/user-guide/images/zookeeper.jpg](http://dubbo.apache.org/docs/zh-cn/user/sources/images/zookeeper.jpg)

流程说明：

- 服务提供者启动时: 向 `/dubbo/com.foo.BarService/providers` 目录下写入自己的 URL 地址
- 服务消费者启动时: 订阅 `/dubbo/com.foo.BarService/providers` 目录下的提供者 URL 地址。并向 `/dubbo/com.foo.BarService/consumers` 目录下写入自己的 URL 地址
- 监控中心启动时: 订阅 `/dubbo/com.foo.BarService` 目录下的所有提供者和消费者 URL 地址。

支持以下功能：

- 当提供者出现断电等异常停机时，注册中心能自动删除提供者信息
- 当注册中心重启时，能自动恢复注册数据，以及订阅请求
- 当会话过期时，能自动恢复注册数据，以及订阅请求
- 当设置 `<dubbo:registry check="false" />` 时，记录失败注册和订阅请求，后台定时重试
- 可通过 `<dubbo:registry username="admin" password="1234" />` 设置 zookeeper 登录信息
- 可通过 `<dubbo:registry group="dubbo" />` 设置 zookeeper 的根节点，不设置将使用无根树
- 支持 `*` 号通配符 `<dubbo:reference group="*" version="*" />`，可订阅服务的所有分组和所有版本的提供者



### Dubbo相关介绍

1. **Dubbo是什么？**

   Dubbo是一个分布式服务框架，致力于提供高性能和透明化的RPC远程服务调用方案，以及SOA服务治理方案。简单的说，dubbo就是个服务框架，如果没有分布式的需求，其实是不需要用的，只有在分布式的时候，才有dubbo这样的分布式服务框架的需求，并且本质上是个服务调用的东东，**说白了就是个远程服务调用的分布式框架（告别Web Service模式中的WSdl，以服务者与消费者的方式在dubbo上注册）**
   其核心部分包含:

   1. 远程通讯: 提供对多种基于长连接的NIO框架抽象封装，包括多种线程模型，序列化，以及“请求-响应”模式的信息交换方式。
   2. 集群容错: 提供基于接口方法的透明远程过程调用，包括多协议支持，以及软负载均衡，失败容错，地址路由，动态配置等集群支持。
   3. 自动发现: 基于注册中心目录服务，使服务消费方能动态的查找服务提供方，使地址透明，使服务提供方可以平滑增加或减少机器。

2. **Dubbo能做什么？**
   1. 透明化的远程方法调用，就像调用本地方法一样调用远程方法，只需简单配置，没有任何API侵入。      
   2. 软负载均衡及容错机制，可在内网替代F5等硬件负载均衡器，降低成本，减少单点。
   3. 服务自动注册与发现，不再需要写死服务提供方地址，注册中心基于接口名查询服务提供者的IP地址，并且能够平滑添加或删除服务提供者。

Dubbo采用全Spring配置方式，透明化接入应用，对应用没有任何API侵入，只需用Spring加载Dubbo的配置即可，Dubbo基于Spring的Schema扩展进行加载。

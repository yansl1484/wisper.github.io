---
title: dubbo学习笔记：快速搭建
date: 2019-05-02 15:59:37
categories:
- dubbo
---

## 搭建一个简单的dubbo服务

参考地址：

dubbo官网:<http://dubbo.apache.org/zh-cn/docs/user/references/registry/zookeeper.html>
博客:<http://www.cnblogs.com/lighten/p/6828026.html>

> 以上两个教程经实践发现都有部分谬误，本教程做了一定更正

### 1.简介

dubbo是一个分布式服务框架，由阿里巴巴的工程师开发，致力于提供高性能和透明化的RPC远程服务调用。可惜的是该项目在2012年之后就没有再更新了，之后由当当基于dubbo开发了dubbox。这里对dubbo的入门构建进行简单的介绍。不涉及dubbo的运行机制，只是搭建过程，方便学习者快速构建项目，运行、熟悉该框架。

dubbo提供了两种构建项目的方法：

1. 通过Spring容器快速构建，其中还有注解的方式；
2. 通过直接使用API（不推荐）。以下对其一一说明。



### 2.spring配置的形式

#### 1.导入maven依赖

```xml
<!--如果引入的是2.6.2以下版本，xml文件头引入的xsd地址会报错-->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.6.3</version>
    <exclusions>
        <exclusion>
            <!-- 排除传递spring依赖 -->
            <artifactId>spring</artifactId>
            <groupId>org.springframework</groupId>
        </exclusion>
    </exclusions>
</dependency>

<!--下面分别是两种不同的zookeeper客户端实现，选择一种就好-->
<dependency>
     <groupId>com.101tec</groupId>
     <artifactId>zkclient</artifactId>
     <version>0.4</version>
 </dependency>

<dependency>
	<groupId>org.apache.curator</groupId>
	<artifactId>curator-framework</artifactId>
	<version>2.12.0</version>
</dependency>

<!--后期可能还会用到如下zookeeper客户端jar包依赖，但是目前这个demo不引入也没有问题-->
<dependency> 
    <groupId>org.apache.zookeeper</groupId>
    <artifactId>zookeeper</artifactId>
    <version>3.3.3</version> 
</dependency>

<!--spring配置方式，自然需要spring相关的依赖-->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>3.2.17.RELEASE</version>
    <exclusions>
        <exclusion>
            <groupId>commons-logging</groupId>
            <artifactId>commons-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>commons-logging</groupId>
    <artifactId>commons-logging</artifactId>
    <version>1.2</version>
</dependency>

<!--打印日志相关-->
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-log4j12</artifactId>
    <version>1.6.4</version>
</dependency>
```

**zkclient和curator**

curator和zkclient分别为两种不同的zookeeper实现，两者使用的同时都需要开启先zookeeper注册中心的服务端。(关于如何下载配置并启动zookeeper服务端，参考[win10环境下搭建zookeeper伪集群](https://app.yinxiang.com/shard/s72/nl/17056971/44168097-530c-40cf-94bb-bf56a8f88a47))
在本项目中，它默认是使用了curator实现的，要改成zkclient实现，需要在`<dubbo:registry address="zookeeper://127.0.0.1:2181/" client="zkclient" />`标签中加入 `client="zkclient"`，并换成zkclient的依赖。
(在dubbo官网中称2.5以上的dubbo版本默认使用zookeeper实现，但是实测结果却相反)



#### 2.定义服务接口(对提供方和调用方都可见)

```java
package dubboXml;

public interface DemoService {
    String sayHello(String name);
}
```



#### 3.服务提供方配置

1. 实现服务接口

   ```java
   package dubboXml;
   
   public class DemoServiceImpl implements DemoService{
       public String sayHello(String name) {
           return "Hello " + name;
       }
   }
   ```

2. spring配置

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
          xsi:schemaLocation="http://www.springframework.org/schema/beans
          http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
          http://dubbo.apache.org/schema/dubbo
          http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
   
       <!-- 提供方应用信息，用于计算依赖关系 -->
       <dubbo:application name="hello-world-app"  />
   
       <!-- 使用zookeeper注册中心暴露服务地址 -->
       <dubbo:registry address="zookeeper://127.0.0.1:2181" client="zkclient" />
   
       <!-- 用dubbo协议在20880端口暴露服务 -->
       <dubbo:protocol name="dubbo" port="20880" />
   
       <!-- 声明需要暴露的服务接口 -->
       <dubbo:service interface="dubboXml.DemoService" ref="demoService" />
   
       <!-- 和本地bean一样实现服务 -->
       <bean id="demoService" class="dubboXml.DemoServiceImpl" />
   </beans>
   ```

3. 读取配置，提供服务

   ```java
   package dubboXml;
   
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   public class Provider {
       public static void main(String[] args) throws Exception {
           ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[] {"provider.xml"});
           context.start();
           System.in.read(); // 按任意键退出
       }
   }
   ```



#### 4.服务调用方配置

1. spring配置

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
          xsi:schemaLocation="http://www.springframework.org/schema/beans
                  http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
                  http://dubbo.apache.org/schema/dubbo
                  http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
   
       <!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
       <dubbo:application name="consumer-of-helloworld-app"  />
   
       <!-- 使用zookeeper注册中心暴露发现服务地址 -->
       <dubbo:registry address="zookeeper://127.0.0.1:2181" />
   
       <!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
       <dubbo:reference id="demoService" interface="dubboXml.DemoService" />
   </beans>
   ```

2. 读取配置，调用服务

   ```java
   package dubboXml;
   
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   public class Consumer {
       public static void main(String[] args) throws Exception {
           ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[] {"consumer.xml"});
           context.start();
           DemoService demoService = (DemoService)context.getBean("demoService"); // 获取远程服务代理
           String hello = demoService.sayHello("nihao"); // 执行远程方法
           System.out.println( hello ); // 显示调用结果
       }
   }
   ```

最终结果:

![](https://markdown-1258758703.cos.ap-chengdu.myqcloud.com/img/20190329002301.png)



#### 5.其他说明

- 如果涉及传输对象，那么被传输的对象类应该实现serializable接口。因为对象远程传输是以二进制的形式进行的，那么在传输之前需要实现序列化。
- 我的demo地址:[demoXml](https://github.com/yansl1484/projDemo/tree/master/dubbo-demo/dubboXml)

我的目录结构:

![](https://markdown-1258758703.cos.ap-chengdu.myqcloud.com/img/20190329002445.png)


<br>
<br>


### 3.注解配置的方式

maven配置同上。

#### 1.服务接口和传输对象

服务接口

```java
package com.common.server;

import java.util.List;

public interface DemoService {

    public String greet(String name);
    public List<User> getUsers();

}
```

传输对象：实现序列化接口

```java
package com.common.server;

import java.io.Serializable;

public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private String name;
    private int age;
    private String sex;

    public User(String name, int age, String sex) {
        this.name = name;
        this.age = age;
        this.sex = sex;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
    public String getSex() {
        return sex;
    }
    public void setSex(String sex) {
        this.sex = sex;
    }

    @Override
    public String toString() {
        return "User [name=" + name + ", age=" + age + ", sex=" + sex + "]";
    }
}

```



#### 2.服务提供方

1. 实现接口(注意加上相应注解)

   ```java
   package com.provider;
   
   import com.alibaba.dubbo.config.annotation.Service;
   import com.common.server.DemoService;
   import com.common.server.User;
   
   import java.util.ArrayList;
   import java.util.List;
   
   /**
    * 实现类上打上service注解：注意，是dubbo的service注解
    */
   @Service
   public class DemoServiceImpl implements DemoService {
   
       @Override
       public String greet(String name) {
           return "Hello " + name;
       }
   
       @Override
       public List<User> getUsers() {
           List<User> list = new ArrayList<>();
   
           User user1 = new User("张三",10,"男");
           User user2 = new User("李四",11,"女");
           User user3 = new User("王五",12,"男");
   
           list.add(user1);
           list.add(user2);
           list.add(user3);
   
           return list;
       }
   
   }
   
   ```

2. xml配置
   (与全xml配置服务的方式相比，这里去掉了bean和`<dubbo:service>`，使用`<dubbo:anotition>`取代了，相当于自动扫描并暴露服务)

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
          xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://code.alibabatech.com/schema/dubbo
       http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
   
       <!-- 提供方应用信息，用于计算依赖关系 -->
       <dubbo:application name="provider"  />
   
       <!-- 使用zookeeper注册中心暴露服务地址 -->
       <dubbo:registry address="zookeeper://127.0.0.1:2181" client="zkclient" />
       <!--<dubbo:registry address="N/A"/>-->
   
       <!-- 用dubbo协议在20880端口暴露服务 -->
       <dubbo:protocol name="dubbo" port="20880" />
   
       <!-- 注解实现，指向服务提供者实现类的包扫描-->
       <dubbo:annotation package="com.provider" />
   </beans>
   ```

   

3. 开启服务提供

   ```java
   package com.provider;
   
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   import java.io.IOException;
   
   /**
    * 服务提供者
    */
   public class Provider {
   
       public static void main(String[] args) throws IOException {
           ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[]{"provider.xml"});
           context.start();
           System.in.read();
       }
   }
   
   ```



#### 3.服务调用方

1. 类中注入并使用远程服务代理（为什么不在加载spring文件的类中注入？因为那是入口)

   ```java
   package com.consumer;
   import com.alibaba.dubbo.config.annotation.Reference;
   import com.common.server.DemoService;
   import org.springframework.stereotype.Component;
   
   /**
    * 服务消费者：service是spring的注解
    */
   @Component("anotationConsumer")
   public class AnotationConsumer {
   
       /**
        * 远程服务代理，可以和本地bean一样使用demoService
        */
       @Reference(check = false)
       private DemoService demoService;
   
       public void print(){
           System.out.println(demoService.greet("张三"));
           System.out.println(demoService.getUsers());
       }
   }
   
   ```

2. consumer.xml spring配置文件

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
          xmlns:context="http://www.springframework.org/schema/context"
          xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context-3.0.xsd
       http://code.alibabatech.com/schema/dubbo
       http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
   
       <dubbo:application name="consumer"/>
   
       <dubbo:registry address="zookeeper://127.0.0.1:2181" client="zkclient" />
   
       <!--指向服务调用者所在的包-->
       <dubbo:annotation package="com.consumer" />
   
       <!-- 配置spring注解包扫描 -->
       <context:component-scan base-package="com.consumer"></context:component-scan>
   
   </beans>
   ```

3. 启动服务

   ```java
   package com.consumer;
   
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   public class Consumer {
   
       public static void main(String[] args) {
           ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[]{"consumer.xml"});
           context.start();
   
           AnotationConsumer anotationConsumer = (AnotationConsumer) context.getBean("anotationConsumer");
           anotationConsumer.print();
       }
   }
   
   ```

调用结果:

![](https://markdown-1258758703.cos.ap-chengdu.myqcloud.com/img/20190329164037.png)



#### 4.附加信息

- 无论是哪种配置方式，如果使用了注册中心，那么注册和调用的时候必须先开启注册中心。
- demo地址：[dubboAnotation](https://github.com/yansl1484/projDemo/tree/master/dubbo-demo/dubboAnotation)
- 还有一种api调用的形式，由于不常用所以这里没有提供教程。如果有兴趣可以查看参考帖。

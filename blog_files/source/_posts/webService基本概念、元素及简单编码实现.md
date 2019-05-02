---
title: webService基本概念、元素及简单编码实现
date: 2019-05-02 16:05:51
categories:
- 云服务
---

#### webService
"网络服务"（Web Service）的本质，就是通过网络调用其他网站的资源。
网络服务是相对于本地服务来说的，本机完成本机需要完成的任务，叫“本地服务”，而“网络服务”则是通过网络来调用其他服务器提供的服务。

>webService和中间件的关系：webService是一种技术手段，是一种网络中系统之间进行交互的方式。而中间件则是实现这种交互的一种手段（一种软件、服务）。

定义：WebService是一种跨编程语言和跨操作系统平台的远程调用技术（rpc）。
实现平台无关性和语言无关性的关键是用一种标准来统一定义相互通信的接口，而WebService平台技术就是旨在解决统一标准的问题。
引用：[Web service是什么？](http://www.ruanyifeng.com/blog/2009/08/what_is_web_service.html)

**WebService平台技术**
XML+XSD,SOAP和WSDL就是构成WebService平台的三大技术。
SOAP和WSDL的详细格式和解析可见：[SOAP和WSDL的一些必要知识](https://www.cnblogs.com/JeffreySun/archive/2009/12/14/1623766.html) or [备用地址](https://www.cnblogs.com/iisme/p/10751456.html)

**XML和XSD：** WebService采用HTTP协议传输数据，采用XML格式封装数据（即XML中说明调用远程服务对象的哪个方法，传递的参数是什么，以及服务对象的返回结果是什么）。
XML是WebService平台中表示数据的格式。除了易于建立和易于分析外，XML主要的优点在于它既是平台无关的，又是厂商无关的。无关性是比技术优越性更重要的：软件厂商是不会选择一个由竞争对手所发明的技术的。
XML解决了数据表示的问题，但它没有定义一套标准的数据类型，更没有说怎么去扩展这套数据类型。例如，整形数到底代表什么？16位，32位，64位？这些细节对实现互操作性很重要。
XML Schema(XSD)就是专门解决这个问题的一套标准。它定义了一套标准的数据类型，并给出了一种语言来扩展这套数据类型。WebService平台就是用XSD来作为其数据类型系统的。当你用某种语言(如VB.NET或C#)来构造一个Web service时，为了符合WebService标准，所有你使用的数据类型都必须被转换为XSD类型。你用的工具可能已经自动帮你完成了这个转换，但你很可能会根据你的需要修改一下转换过程。
> xsd就是基于xml，自己定义了一套标签，用来对webService中的数据表示格式进一步规范。

**SOAP：** WebService通过HTTP协议发送请求和接收结果时，发送的请求内容和结果内容都采用XML格式封装，并增加了一些特定的HTTP消息头，以说明HTTP消息的内容格式，这些特定的HTTP消息头和XML内容格式就是SOAP协议。SOAP提供了标准的RPC方法来调用Web Service。SOAP协议 = HTTP协议 + XML
数据格式SOAP协议定义了SOAP消息的格式，SOAP协议是基于HTTP协议的，SOAP也是基于XML和XSD的，XML是SOAP的数据编码方式。打个比喻：HTTP就是普通公路，XML就是中间的绿色隔离带和两边的防护栏，SOAP就是普通公路经过加隔离带和防护栏改造过的高速公路。
> soap基于xml和http，在http的请求头中加入属性用以标记请求内容格式是soap类型的，并且用soap也是和xsd一样，基于xml的基础上自己定义一套标签，来规范webService请求的一系列参数。

**WSDL：** 好比我们去商店买东西，首先要知道商店里有什么东西可买，然后再来购买，商家的做法就是张贴广告海报。 WebService也一样，WebService客户端要调用一个WebService服务，首先要有知道这个服务的地址在哪，以及这个服务里有什么方法可以调用，所以，WebService务器端首先要通过一个WSDL文件来说明自己家里有啥服务可以对外调用，服务是什么（服务中有哪些方法，方法接受的参数是什么，返回值是什么），服务的网络地址用哪个url地址表示，服务通过什么方式来调用。
WSDL(Web Services Description Language)就是这样一个基于XML的语言，用于描述Web Service及其函数、参数和返回值。它是WebService客户端和服务器端都能理解的标准格式。因为是基于XML的，所以WSDL既是机器可阅读的，又是人可阅读的，这将是一个很大的好处。一些最新的开发工具既能根据你的Web service生成WSDL文档，又能导入WSDL文档，生成调用相应WebService的代理类代码。
WSDL文件保存在Web服务器上，通过一个url地址就可以访问到它。客户端要调用一个WebService服务之前，要知道该服务的WSDL文件的地址。WebService服务提供商可以通过两种方式来暴露它的WSDL文件地址：1.注册到UDDI服务器，以便被人查找；2.直接告诉给客户端调用者。
> WSDL也是在xml的基础上进行扩展，它是用来描述webservice的，描述了WebService有哪些方法、参数类型、访问路径等等。

**UDDI：** UDDI的目的是为电子商务建立标准；UDDI是一套基于Web的、分布式的、为Web Service提供的、信息注册中心的实现标准规范，同时也包含一组使企业能将自身提供的Web Service注册，以使别的企业能够发现的访问协议的实现标准。也即一种远程服务发布与注册的标准。

-----

#### Web Service调用方式
网络上随处可见的“四种调用webService的方式”都是通过jdk1.6之后集成的组件api进行调用。
随处找来的：[WebService的四种客户端调用方式（基本）](https://blog.csdn.net/menghuanzhiming/article/details/78475785)
还有其他的开源框架实现了Web Service，比如axis和cxf。

在SOA领域，我们认为Web Service是SOA体系的构建单元（building block）。对于服务开发人员来说，AXIS和CXF一定都不会陌生。这两个产品都是Apache孵化器下面的Web Service开源开发工具。 Axis2的最新版本是1.3.CXF现在已经到了2.0版本。 

这两个框架 都是从已有的开源项目发展起来的。Axis2是从Axis1.x系列发展而来。CXF则是XFire和Celtix项目的结合产品。Axis2是从底层全部重新实现，使用了新的扩展性更好模块架构。 CXF也重新的深化了XFire和Celtix这两个开发工具。 

新产品的退出导致了几个问题。是不是现有的使用Axis 1.x，XFire和Celix的应用需要迁移的新的版本上。如果一个开发人员确定要迁移它的应用到新的框架上，那么他应该选择哪一个呢？相反的，如果一个开发者决定从头开发一个新的Web Service，他应该使用哪个呢？ 这两个框架哪一个更好一些呢？ 

对于系统迁移来说，也许迁移到新的框架并不难。Axis和CXF都提供了迁移的指导。能够给开发者一些迁移的技巧和经验。但是对于这样迁移，这两个开源项目都没有提供迁移的工具。对于这样的迁移工作，尽管很值得去寻找所有的可行方案。Axis2和CXF都有各自不同的WebService开发方法，每个方法都有相当数量拥护者。 

通过一个比较矩阵来比较Axis2和CXF变得有现实的意义。这两个项目都开发不够成熟，但是最主要的区别在以下几个方面： 

1.CXF支持 WS-Addressing，WS-Policy， WS-RM， WS-Security和WS-I Basic Profile。Axis2不支持WS-Policy，但是承诺在下面的版本支持。 

2. CXF可以很好支持Spring。Axis2不能 

3. AXIS2支持更广泛的数据并对，如XMLBeans，JiBX，JaxMe和JaxBRI和它自定义的数据绑定ADB。注意JaxME和JaxBRI都还是试验性的。CXF只支持JAXB和Aegis。在CXF2.1 

4. Axis2支持多语言-除了Java,他还支持C/C++版本。 

比较这两个框架的Web Service开发方法与比较它们的特性同样重要。 从开发者的角度，两个框架的特性相当的不同。 Axis2的开发方式类似一个小型的应用服务器，Axis2的开发包要以WAR的形式部署到Servlet容器中，比如Tomcat，通过这些容器可以对工作中的Web Service进行很好的监控和管理。Axis2 的Web administrion模块可以让我们动态的配置Axis2.一个新的服务可以上载，激活，使之失效，修改web服务的参数。管理UI也可以管理一个或者多个处于运行状态的服务。这种界面化管理方式的一个弊端是所有在运行时修改的参数没有办法保存，因为在重启动之后，你所做的修改就会全部失效。 

Axis2允许自己作为独立的应用来发布Web Service，并提供了大量的功能和一个很好的模型，这个模型可以通过它本身的架构（modular architecture）不断添加新的功能。有些开发人员认为这种方式对于他们的需求太过于繁琐。这些开发人员会更喜欢CXF。 

CXF更注重开发人员的工效（ergonomics）和嵌入能力（embeddability）。大多数配置都可以API来完成，替代了比较繁琐的XML配置文件， Spring的集成性经常的被提及，CXF支持Spring2.0和CXF's API和Spring的配置文件可以非常好的对应。CXF强调代码优先的设计方式（code-first design)，使用了简单的API使得从现有的应用开发服务变得方便。 

不过你选择Axis2还是CXF，你都可以从开源社区得到大量的帮助。这两个框架都有商业公司提供服务，WSO2提供AXIS2的支持，Iona提供CXF的支持。这两公司都有很活跃的开发者社区。 Axis2出现的时间较早，CXF的追赶速度快。我的建议是：如果你需要多语言的支持，你应该选择AXIS2。如果你需要把你的实现侧重JAVA并希望和Spring集成，CXF就是更好的选择，特别是把你的Web Service嵌入其他的程序中。如果你觉得这两个框架的新特性对于你并没有太大的用处，你会觉得Axis1也是不错的选择，你应该继续使用它知道你有充分的理由去更换它。

#### cxf方式调用webService

参考链接：[CXF提供Client调用WebService接口的方法](http://www.voidcn.com/article/p-rgqzsmib-bkv.html)

 1、  JaxWsProxyFactoryBean  
   简介： 调用方式采用了和RMI类似的机制，即客户端直接服务器端提供的服务接口(interface),CXF通过运行时代理生成远程服务的代理对象，在客户端完成对webservice的访问; 几个必填的字段：setAddress-这个就是我们发布webservice时候的地址，保持一致
     缺点： 这种调用service的好处在于调用过程非常简单，就几行代码就完成一个webservice的调用，但是客户端也必须依赖服务器端的接口，这种调用方式限制是很大的，要求服务器端的webservice必须是java实现--这样也就失去了使用webservice的意义
```java
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
public class Client {  
    public static void main(String[] args) {  
        JaxWsProxyFactoryBean bean = new JaxWsProxyFactoryBean();  
        bean.setServiceClass(HelloWorldService.class);  
        bean.setAddress("http://localhost:9090/helloWorldService");  
        HelloWorldService helloWorldService = (HelloWorldService)bean.create();  
        String result = helloWorldService.sayHello("Kevin");  
        System.out.println(result);  
    } 
```

2、 JaxWsDynamicClientFactory  [Dynamic：动态的]
     简介： 只要指定服务器端wsdl文件的位置，然后指定要调用的方法和方法的参数即可，不关心服务端的实现方式。
    wsdl [Web Services Description Language]网络服务描述语言是Web Service的描述语言，它包含一系列描述某个web service的定义
```java
import org.apache.cxf.jaxws.endpoint.dynamic.JaxWsDynamicClientFactory;
public class Client2 {  
    public static void main(String[] args) throws Exception {  
        JaxWsDynamicClientFactory clientFactory = JaxWsDynamicClientFactory.newInstance();  
        Client client = clientFactory.createClient("http://localhost:9090/helloWorldService?wsdl");  
        Object[] result = client.invoke("sayHello", "KEVIN");  
        System.out.println(result[0]);  
    }  
}  
```


3、JaxWsServerFactoryBean
     用JaxWsServerFactoryBean发布，需要独立的jetty包。

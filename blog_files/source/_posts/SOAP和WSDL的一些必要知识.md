---
title: SOAP和WSDL的一些必要知识
date: 2019-05-02 16:03:29
categories:
- 云服务
---

原文地址：https://www.cnblogs.com/JeffreySun/archive/2009/12/14/1623766.html
SOAP和WSDL对Web Service、WCF进行深入了解的基础，因此花一些时间去了解一下是很有必要的。

一、SOAP(Simple Object Access Protocol)

如果我们要调用远程对象的方法，就必定要告诉对方，我们要调用的是一个什么方法，以及这个方法的参数的值等等。然后对方把数据返回给我们。

这其中就涉及到两个问题：1、数据如何在网络上传输。2、如何表示数据？用什么格式去表示函数以及它的参数等等。

1、SOAP的传输协议

SOAP的传输协议使用的就是HTTP协议。只不过HTTP传输的内容是HTML文本，而SOAP协议传输的是SOAP的数据。看一下下面的例子：

这是一个HTTP请求(请求google的首页)的内容:
```
GET / HTTP/1.1 Accept: image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*
Accept-Language: en-us
User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; CIBA) chromeframe/4.0
Accept-Encoding: gzip, deflate
Connection: Keep-Alive
Host: www.google.com
Cookie: PREF=ID=d8f9f1710bfa5f72:U=a5b3bec86b6433ef:NW=1:TM=1260238598:LM=1260241971:GM=1:S=q2agYsw3BsoOQMAs; NID=29=JgIGDDUx70IQTBVAnNEP_E9PLLKBI9STjzaBjgq1eWuDg-_jCgFpka59DrOC0aZKLbj4q77HU1VMKscXTP3OaseyTbv643c2XPe9dS7lsXDHAkAnS46vy-OU8XRqbmxJ; rememberme=true; SID=DQAAAH4AAABW7M4nVkTeOR7eJUmC1AJ4R6hYbmVewuy_uItLUTzZMUTpojdaHUExhPa_EPAkO9Ex1u3r7aPXZ5cj28xHnv2DbfRYf5AyaBcimciuOTITKSIkqn3QSpGDFkRS1Xn7EGzDpCV0V1xFlCu0erf_jfe_D6GOgC2P2S08jNdFS9Vpmw; HSID=AFEFTMA68EgNjkbil; __utmx=173272373.; __utmxx=173272373.
---------如果有Post的数据，这里还会有Post的数据--------
```

这个是一个SOAP请求的内容：
```
POST /WebServices/WeatherWebService.asmx HTTP/1.1
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 2.0.50727.3603)
Content-Type: text/xml; charset=utf-8
SOAPAction: "http://WebXml.com.cn/getSupportCity"
Host: www.webxml.com.cn
Content-Length: 348
Expect: 100-continue
Connection: Keep-Alive

<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><getSupportCity xmlns="http://WebXml.com.cn/"><byProvinceName>广东</byProvinceName></getSupportCity></soap:Body></soap:Envelope>
```

可以看到，一个SOAP请求其实就是一个HTTP请求，但为了表明内容是SOAP的数据，需要加入上面请求中红色字的部分来以示区别。也就是说，如果请求头中有SOAPAction这一段，那么请求会被当作SOAP的内容来处理而不会当作HTML来解析。可以用上面指定SOAPAction头来表示内容是SOAP的内容，也可以指定 Content-Type: application/soap+xml 来表示内容是SOAP的内容。SOAP请求中最后的那段XML数据，这个就是请求的具体内容，这个就是SOAP规定的请求的数据格式，下面再详细对格式进行说明。

 

2、SOAP的数据格式

现在知道了SOAP是通过HTTP协议的POST方法来传输数据的，只不过是请求的Header中加了一些标志来说明自己是一个SOAP请求。那么数据的具体格式是怎么规定的呢，我们把上面请求的XML数据展开看一下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
        <getSupportCity xmlns="http://WebXml.com.cn/">
            <byProvinceName>广东</byProvinceName>
        </getSupportCity>
    </soap:Body>
</soap:Envelope>
```
其中的\<soap:Body\>里面的内容就是请求的内容，请求的方法为getSupportCity，该方法有一个名为byProvinceName的参数，参数的值为“广东”这个字符串。再看一下返回的内容：
```xml
<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><getSupportCityResponse xmlns="http://WebXml.com.cn/"><getSupportCityResult><string>广州 (59287)</string><string>深圳 (59493)</string><string>潮州 (59312)</string><string>韶关 (59082)</string><string>湛江 (59658)</string><string>惠州 (59298)</string><string>清远 (59280)</string><string>东莞 (59289)</string><string>江门 (59473)</string><string>茂名 (59659)</string><string>肇庆 (59278)</string><string>汕尾 (59501)</string><string>河源 (59293)</string><string>揭阳 (59315)</string><string>梅州 (59117)</string><string>中山 (59485)</string><string>德庆 (59269)</string><string>阳江 (59663)</string><string>云浮 (59471)</string><string>珠海 (59488)</string><string>汕头 (59316)</string><string>佛山 (59279)</string></getSupportCityResult></getSupportCityResponse></soap:Body></soap:Envelope>
```
返回的HTTP头中并没有标志来表明是一个SOAP的响应，因为的确没有必要，请求方发送出的SOAP请求，返回的肯定是SOAP的响应。

 

一个典型的SOAP请求格式的结构如下：
```xml
<?xml version="1.0"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2001/12/soap-envelope"
soap:encodingStyle="http://www.w3.org/2001/12/soap-encoding">

<soap:Header>
  <m:Trans xmlns:m="http://www.w3schools.com/transaction/"
  soap:mustUnderstand="1">234
  </m:Trans>
</soap:Header>

<soap:Body>
  <m:GetPrice xmlns:m="http://www.w3schools.com/prices">
    <m:Item>Apples</m:Item>
  </m:GetPrice>
</soap:Body>

</soap:Envelope>
```

下面逐个解释里面的元素:

a) Envelope

SOAP的请求内容必须以Envelope做为根节点。

xmlns:soap="http://www.w3.org/2001/12/soap-envelope"，不能修改，否则会出错。http://www.w3.org/2001/12/soap-envelope里面有Envelope的schema的相关定义。有兴趣的可以去这个链接的内容。

soap:encodingStyle="http://www.w3.org/2001/12/soap-encoding"，这个指定了数据元素的类型。

 

b) Header

这个是可选的，如果需要添加Header元素，那么它必须是Envelope的第一个元素。

Header的内容并没有严格的限制，我们可以自己添加一些和应用程序相关的内容，但是客户端一定要记得处理这些Header元素，可以加上mustUnderstand强制进行处理。

 

c) Body

这个就是请求的主题内容了，请求什么函数，参数是什么类型等等都在这里面指定。 

用标签表示一个函数，然后用子元素表示它的参数。

  

在调用中没有指定参数和返回类型，这里不需要指定，因为提供服务的一方自己已经规定好了数据类型，在调用时指定数据类型没有任何意义。

 

二、WSDL(Web Services Description Language)

　　WSDL是用来描述WebService的，它用XML的格式描述了WebService有哪些方法、参数类型、访问路径等等。我们要使用一个WebService肯定首先要获取它的WSDL，在VS中添加一个Web 引用时，这些工作由开发环境帮我们做了，开发环境根据WSDL文档给Web Service生成了相应的代理类供我们使用。

下面是一个HelloWorld的WebService的服务端代码：

```asp.net
public class Service : System.Web.Services.WebService
{
    public Service () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public DateTime HelloWorld(int i)
    {
        return DateTime.Now;
    }
}
```

其对应的WebService的WSDL文档如下：

```xml
<?xml version="1.0" encoding="utf-8"?>
<wsdl:definitions xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:tns="http://tempuri.org/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" targetNamespace="http://tempuri.org/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">
  <wsdl:types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://tempuri.org/">
      <s:element name="HelloWorld">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="1" maxOccurs="1" name="i" type="s:int" />
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="HelloWorldResponse">
        <s:complexType>
          <s:sequence>
            <s:element minOccurs="1" maxOccurs="1" name="HelloWorldResult" type="s:dateTime" />
          </s:sequence>
        </s:complexType>
      </s:element>
    </s:schema>
  </wsdl:types>
  <wsdl:message name="HelloWorldSoapIn">
    <wsdl:part name="parameters" element="tns:HelloWorld" />
  </wsdl:message>
  <wsdl:message name="HelloWorldSoapOut">
    <wsdl:part name="parameters" element="tns:HelloWorldResponse" />
  </wsdl:message>
  <wsdl:portType name="ServiceSoap">
    <wsdl:operation name="HelloWorld">
      <wsdl:input message="tns:HelloWorldSoapIn" />
      <wsdl:output message="tns:HelloWorldSoapOut" />
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="ServiceSoap" type="tns:ServiceSoap">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http" />
    <wsdl:operation name="HelloWorld">
      <soap:operation soapAction="http://tempuri.org/HelloWorld" style="document" />
      <wsdl:input>
        <soap:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:binding name="ServiceSoap12" type="tns:ServiceSoap">
    <soap12:binding transport="http://schemas.xmlsoap.org/soap/http" />
    <wsdl:operation name="HelloWorld">
      <soap12:operation soapAction="http://tempuri.org/HelloWorld" style="document" />
      <wsdl:input>
        <soap12:body use="literal" />
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal" />
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="Service">
    <wsdl:port name="ServiceSoap" binding="tns:ServiceSoap">
      <soap:address location="http://localhost:2206/WebSite1/Service.asmx" />
    </wsdl:port>
    <wsdl:port name="ServiceSoap12" binding="tns:ServiceSoap12">
      <soap12:address location="http://localhost:2206/WebSite1/Service.asmx" />
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
```

一个WSDL文档由四部分组成：

1、types

　　指定了WebService用到的所有数据类型，上面用到了两种数据类型，int和datetime


2、message

　　指明一个操作所用到的数据类型。

　　HelloWorldSoapIn是指HelloWorld的输入操作用到的数据类型，HelloWorldSoapOut是指HelloWorld的输出操作用到的数据类型。二者的element元素指出了与types中对应到的具体类型。

 

3、portType

　　指出了这个WebService所有支持的操作，就是说有哪些方法可供调用。

　　这里支持一个HelloWorld调用，它的输入和输出对应到HelloWorldSoapIn和HelloWorldSoapOut这个两个数据类型。

 

4、binding

　　soap12:binding元素的transport指明传输协议，这里是http协议。

　　operation 指明要暴露给外界调用的操作。

　　use属性指定输入输出的编码方式，这里没有指定编码。

 

5、services

　　指定服务的一些信息，主要是指定服务的访问路径。

(:
 : Copyright 2010 XQuery.me
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
:)

(:~
 : <p>
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';

import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace hash = "http://www.zorba-xquery.com/modules/cryptography/hash";
import module namespace base64 = "http://www.zorba-xquery.com/modules/converters/base64";
import module namespace hmac = "http://www.zorba-xquery.com/modules/cryptography/hmac";

(:~
 : create an http request
 :
 : @param $method the http method to be used for the request (GET,POST,PUT,HEAD,...)
 : @param $href the targeted href URL for the request
 : @return the newly created http request
:)
declare function request:create(
    $method as xs:string,
    $href as xs:string) as element(http:request) {

    <http:request method="{upper-case($method)}"
                  href="{$href}">
        <http:header name="x-amz-date" value="{utils:http-date()}" />
        <http:header name="Date" value="{utils:http-date()}" />
    </http:request>
};

(:~
 : Create an http request with a query string build with the provided parameters
 :
 : @param $method the http method to be used for the request (GET,POST,PUT,HEAD,...)
 : @param $href the targeted href URL for the request
 : @param $parameters a sequence of <code>parameter</code> elements each having a <code>name</code>
 :                    and a <code>value</code> attribute.
 : @return the newly created http request
:)
declare function request:create(
    $method as xs:string,
    $href as xs:string,
    $parameters as element(parameter)*) as element(http:request) {
    request:create($method,$href,$parameters,(), (),(),())
};

(:~
 : Create an http request with a query string build with the provided parameters.
 :
 : @param $method the http method to be used for the request (GET,POST,PUT,HEAD,...)
 : @param $href the targeted href URL for the request
 : @param $parameters a sequence of <code>parameter</code> elements each having a <code>name</code>
 :                    and a <code>value</code> attribute.
 : @param $headers a sequence of <code>header</code> elements each having a <code>name</code>
 :                    and a <code>value</code> attribute.
 : @return the newly created http request
:)
declare function request:create(
    $method as xs:string,
    $href as xs:string,
    $parameters as element(parameter)*,
    $headers as element(header)*) as element(http:request) {
    request:create($method,$href,$parameters,$headers, (),(),())
};

(:~
 : Create an http request with a query string build with the provided parameters
 :
 : @param $method the http method to be used for the request (GET,POST,PUT,HEAD,...)
 : @param $href the targeted href URL for the request
 : @param $parameters a sequence of <code>parameter</code> elements each having a <code>name</code>
 :                    and a <code>value</code> attribute.
 : @param $headers a sequence of <code>header</code> elements each having a <code>name</code>
 :                    and a <code>value</code> attribute.
 : @param $content-type a string defining the content type of the body data
 : @param $content the data to be send in the body of the request
 : @return the newly created http request
:)
declare function request:create(
    $method as xs:string,
    $href as xs:string,
    $parameters as element(parameter)*,
    $headers as element(header)*,
    $media-type as xs:string?,
    $serialize-method as xs:string?,
    $content as item()?) as element(http:request) {

    let $query := 
        string-join(
            for $param at $idx in $parameters
            order by $param/@name
            return concat(encode-for-uri(string($param/@name)),if(string($param/@value))then concat("=",encode-for-uri(string($param/@value)))else ())
            ,"&amp;")
    let $headers := for $header in $headers
                    return <http:header>{$header/@*}</http:header>
    let $body := if($media-type and $serialize-method)
                 then <http:body media-type="{$media-type}" method="{$serialize-method}">{$content}</http:body>
                 else ()
    return
        <http:request method="{$method}"
                      href="{$href}{if($query)then concat("?",$query) else ()}">
            <http:header name="x-amz-date" value="{utils:http-date()}" />
            <http:header name="Date" value="{utils:http-date()}" />
            {$headers}
            {$body}
        </http:request>
};

(:~
 : creates an http request URL with the correct protocol provided by the <code>$aws-config</code> element.
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS.
 : @param $target-url the targeted href URL without protocol
 : @return the http request URL
:)
declare function request:href(
    $aws-config as element(aws-config),
    $target-url as xs:string) as xs:string {
    
    let $target-url :=
        switch (true())
         case starts-with($target-url,"https://") 
             return substring-after($target-url, "https://")
         case starts-with($target-url,"http://") 
             return substring-after($target-url, "http://")
         default return $target-url
    let $protocol :=
        if($aws-config/use-https/text() eq "true")then "https://" else "http://"
    return
        concat($protocol, $target-url)
};


(:~
 : Adds the Authorization header to the request according to 
 : <a href="http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAuthentication.html">Amazon S3 RESTAuthentication</a>
 :)
declare updating function request:sign-v2(
  $request as element(http:request),
  $host as xs:string,
  $path as xs:string,
  $version as xs:string?,
  $parameters as element(parameter)*,
  $aws-key as xs:string,
  $aws-secret as xs:string) 
{
  
  let $date as xs:string := utils:timestamp()
  let $signature-parameters :=
      (
          <parameter name="AWSAccessKeyId" value="{$aws-key}" />,
          <parameter name="Timestamp" value="{$date}" />,
          <parameter name="SignatureVersion" value="2" />,
          <parameter name="SignatureMethod" value="HmacSHA1" />,
          utils:if-then ($version,
              <parameter name="Version" value="{$version}" />)
      )
  let $canonical as xs:string :=
      (: trace( :)
          string-join(
              (
                  (: method :)
                  string($request/@method),"&#10;",
                  
                  $host,"&#10;",
                  
                  (: path :)
                  $path,"&#10;",
                  
                  (: parameters :)
                  string-join(
                      for $param in ($parameters,$signature-parameters)
                      let $name := encode-for-uri(string($param/@name))
                      let $value := encode-for-uri(string($param/@value))
                      order by $name
                      return concat($name, "=",$value),"&amp;")
             )
          ,"")
          (:,"canonicalString"):)
  let $signature as xs:string := hmac:sha1($canonical,$aws-secret)
  let $auth-param := <parameter name="Signature" value="{$signature}" />
  let $new-href as xs:string :=
      concat(
          string($request/@href),"&amp;",
          string-join(
              for $param in ($signature-parameters,$auth-param)
              let $name := encode-for-uri(string($param/@name))
              let $value := encode-for-uri(string($param/@value))
              order by $name
              return concat($name, "=",$value),"&amp;"))
  return replace value of node $request/@href with $new-href
};

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
 :      Contains functions to create a request.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace request = 'http://www.xquery.me/modules/xaws/iam/request';

import module namespace common_request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace http = "http://expath.org/ns/http-client";
import module namespace error = 'http://www.xquery.me/modules/xaws/iam/error';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';

declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : send an http request and return the response which is usually a pair of two items: One item containing the response
 : headers, status code,... and one item representing the response body (if any).
 :
 : @return the http response
:)
declare %ann:sequential function request:send(
    $aws-config as element(aws-config)?,
    $request as element(http:request),
    $parameters as element(parameter)*) as item()* {
    
    (: sign the request :)
    if($aws-config)
    then
      common_request:sign-v2(
        $request,
        "iam.amazonaws.com",
        "/",
        "2010-05-08" (: API version :),
        $parameters,
        string($aws-config/aws-key/text()),
        string($aws-config/aws-secret/text()));
    else ();
                  
    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    return
        
        if($status = (200,204)) 
        then $response
        else error:throw($status,$response)

};

(:~
 : send an http request to the security token service (STS) and return the response which is usually a pair of two items: One item containing the response
 : headers, status code,... and one item representing the response body (if any).
 :
 : @return the http response
:)
declare %ann:sequential function request:send-sts(
    $aws-config as element(aws-config)?,
    $request as element(http:request),
    $parameters as element(parameter)*) as item()* {
    
    (: sign the request :)
    if($aws-config)
    then
      common_request:sign-v2(
        $request,
        "sts.amazonaws.com",
        "/",
        "2011-06-15" (: API version :),
        $parameters,
        string($aws-config/aws-key/text()),
        string($aws-config/aws-secret/text()));
    else ();
                  
    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    return
        
        if($status = (200,204)) 
        then $response
        else error:throw($status,$response)

};

(:~
 : creates an http request URL using the https protocol. IAM does only support https.
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
    let $protocol := "https://" (: only supports https! :)
    return
        concat($protocol, $target-url)
};

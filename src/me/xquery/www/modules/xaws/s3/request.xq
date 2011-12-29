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
module namespace request = 'http://www.xquery.me/modules/xaws/s3/request';

import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace common_request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace factory = 'http://www.xquery.me/modules/xaws/s3/factory';
import module namespace error = 'http://www.xquery.me/modules/xaws/s3/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace hmac = "http://www.zorba-xquery.com/modules/cryptography/hmac";

declare namespace ann = "http://www.zorba-xquery.com/annotations";



(:~
 : This function signs an S3 request, sends it and returns the response which is usually 
 : a pair of two items: One item containing the response headers, status code,... and one 
 : item representing the response body (if any).
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $request The http request that was created using the <code>create</code> function of the 
 :                 <a href="http://www.xquery.me/modules/xaws/helpers/request">request</a> module.
 : @param $bucket-name The bucket name which is used in the context of the S3 request.
 : @param $object-key The key of the object (if any) which is used in the context of the S3 request.
 : @return the http response
:)
declare %ann:sequential function request:send(
    $aws-config as element(aws-config),
    $request as element(http:request),
    $bucket-name as xs:string,
    $object-key as xs:string) as item()+ {

    (: sign the request :)
    request:sign(
        $request,
        $bucket-name,
        $object-key,
        string($aws-config/aws-key/text()),
        string($aws-config/aws-secret/text()));

    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    return
        if($status = (200,204)) 
        then $response
        else error:throw($status,$response)
};

(:~
 : Adds the Authorization header to the request according to 
 : <a href="http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAuthentication.html">Amazon S3 RESTAuthentication</a>
 :  
:)
declare updating function request:sign(
    $request as element(),
    $bucketname as xs:string,
    $object-key as xs:string,
    $aws-key as xs:string,
    $aws-secret as xs:string) {
    let $canonical as xs:string :=
          (: trace( :) 
           string-join(
                (
                    (: method :)
                    string($request/@method),"&#10;",
                    
                    (: content-md5 :)
                    string($request/http:header[lower-case(@name)="content-md5"]/@value),"&#10;",
                    
                    (: content-type :)
                    string($request/http:body/@media-type),"&#10;",
                    
                    (: date :)
                    if (not($request/http:header[@name eq "x-amz-date"])) then string($request/http:header[lower-case(@name)="date"]/@value)else (),"&#10;",
                    
                    (: x-amz- headers :)
                    (: @TODO support lists of more than one of the same x-amz-* headers :)
                    for $header in $request/http:header[starts-with(lower-case(string(@name)),"x-amz-")]
                    let $name := lower-case(string($header/@name))
                    let $value := normalize-space(string($header/@value))
                    group by $name
                    order by $name
                    return 
                        ( $name, ":", string-join($value,","), "&#10;" ),
                        
                    (: add complete key :)
                    "/",
                    if ($bucketname eq "") then () else (lower-case($bucketname),"/"),
                    if ($object-key eq "") then () else lower-case($object-key),
                    
                    (: @TODO: add eventually acl, location, logging, versions or torrent parameters from url :)
                    let $href := string($request/@href)
                    let $query := substring-before(substring-after(string($request/@href),"?"),"#")
                    let $key_values := tokenize($query, "&amp;")
                    for $key_value in $key_values
                    let $key := tokenize($key_value,"=")[1]
                    let $value := tokenize($key_value,"=")[2]
                    return ()
               )
            ,"")
            (: ,"canonicalString") :)
    let $signature as xs:string := hmac:sha1($canonical,$aws-secret)
    let $auth-header := <http:header name="Authorization" value="AWS {$aws-key}:{$signature}" />
    return insert node $auth-header as first into $request
};



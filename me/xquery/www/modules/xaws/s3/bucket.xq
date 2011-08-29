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
 :    
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 :)
module namespace bucket = 'http://www.xquery.me/modules/xaws/s3/bucket';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";

import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace s3_request = 'http://www.xquery.me/modules/xaws/s3/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/s3/error';
import module namespace factory = 'http://www.xquery.me/modules/xaws/s3/factory';

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";
declare namespace s3 = "http://doc.s3.amazonaws.com/2006-03-01";

(:~
 : Deletes the bucket provided as parameter or the context bucket if no <code>$bucket</code> parameter is given. 
 :
 : This operation will fail if the deleted bucket is not empty. All objects, object versions, and delete markers have to be deleted beforehand using the <code>delete</code>
 : function of the <a href="http://www.xquery.me/modules/xaws/s3/object">object</a> module.
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to be deleted  
 : @return returns the http response information (header,statuscode,...) 
:)
declare sequential function bucket:delete(
    $aws-config as element(aws-config), 
    $bucket as xs:string?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("DELETE",$href)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : List all buckets of the authenticated user identified by the <code>$aws-config</code>.
 :
 : Example Response (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Owner>
 :        <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :        <DisplayName>XQuery.me</DisplayName>
 :      </Owner>
 :      <Buckets>
 :        <Bucket>
 :            <Name>test.XQuery.me</Name>
 :            <CreationDate>2010-11-03T17:42:45.000Z</CreationDate>
 :        </Bucket>
 :      </Buckets>
 :   </ListAllMyBucketsResult>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListAllMyBucketsResult element 
:)
declare sequential function bucket:list(
    $aws-config as element(aws-config)
) as item()* {

    let $href as xs:string := request:href($aws-config, "s3.amazonaws.com")
    let $request := request:create("GET",$href)
    let $response := s3_request:send($aws-config,$request,(:empty bucket name:)"",(:empty object key:)"")
    return 
        $response
};

(:~
 : List objects (default) or object versions (needs to be enabled in <code>$list-config</code>) contained 
 : within a bucket.
 : 
 : If the <code>$list-config</code> element is empty or does not contain all configuration parameters
 : the following default values for list requests will be used:
 : <ul>
 :    <li><code>delimiter</code>: None</li>
 :    <li><code>marker</code>: None</li>
 :    <li><code>max-keys</code>: "1000"</li>
 :    <li><code>prefix</code>: None</li>
 :    <li><code>list-versions</code>: false</li>
 :    <li><code>version-id-marker</code>: None</li>
 : </ul>
 : This function can only fetch a maximum of 1000 object keys (in alphabetical order). If a bucket contains more 
 : than 1000 objects the result will contain <code>&lt;IsTruncated>true&lt;/IsTruncated></code> and you will have 
 : to do multiple calls to the list function and use the marker configuration to fetch all object keys. 
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $list-config an optional <code>list-config</code> element containing specific configuration for listing a bucket's content.
 :                     Example <code>list-config</code> element:
 :                     <code type="xml">
 :                         <list-config>
 :
 :                             <!-- the delimiter marks where the listed results stop. For example, a delimiter / 
 :                                  lists all objects starting with $prefix plus arbitrary characters but not / -->
 :                             <delimiter>/</delimiter>
 :
 :                             <!-- specifies a key as starting point; following keys (lexicographically greater 
 :                                  than the marker) in alphabetical order are listed -->
 :                             <marker>test/marker</marker>
 : 
 :                             <!-- the maximum number of keys returned (default: "1000"). If more keys than max-keys 
 :                                  can be fetched, the result contains <IsTruncated>true</IsTruncated> -->
 :                             <max-keys>500</max-keys> 
 :
 :                             <!-- only keys starting with the prefix are returned -->
 :                             <prefix>test/</prefix>
 :
 :                             <!-- defines whether object versions should be listed -->
 :                             <list-versions>true</list-versions>
 :
 :                             <!-- the object version id to start the listing from -->
 :                             <version-id-marker>1</version-id-marker>
 :                         </list-config>
 :                     </code> 
 : @param $bucket the name of the bucket to list the contained objects (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: a node of a ListBucketResult
:)
declare sequential function bucket:list(
    $aws-config as element(aws-config),
    $list-config as element(list-config)?,
    $bucket as xs:string?
) as item()* {
    
    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $parameters := 
        if($list-config)
        then
        (
            if($list-config/list-versions/text() eq "true") then <parameter name="versions" value="" /> else (),
            if($list-config/delimiter/text()) then <parameter name="delimiter" value="{$list-config/delimiter/text()}" /> else (),
            if($list-config/marker/text()) then <parameter name="marker" value="{$list-config/marker/text()}" /> else (),
            if($list-config/max-key/text()) then <parameter name="max-key" value="{$list-config/max-key/text()}" /> else (),
            if($list-config/prefix/text()) then <parameter name="prefix" value="{$list-config/prefix/text()}" /> else (),
            if($list-config/version-id-marker/text()) then <parameter name="version-id-marker" 
                                                                      value="{$list-config/version-id-marker/text()}" /> else ()
        )
        else ()
    let $request := request:create("GET",$href,$parameters)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Create a bucket for the authenticated user who will be the bucket owner. For restrictions on bucket names please
 : refer to <a href="http://docs.amazonwebservices.com/AmazonS3/2006-03-01/dev/index.html?UsingBucket.html">Working
 : with Amazon S3 Buckets</a>.
 :
 : If the <code>$create-config</code> element is empty or does not contain all configuration parameters
 : the following default values for creating a bucket will be used:
 : <ul>
 :    <li><code>location</code>: "US"</li>
 :    <li><code>acl</code>: "private"</li>
 : </ul>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $create-config an optional <code>create-config</code> element containing specific configuration for creating a bucket.
 :                     Example <code>create-config</code> element:
 :                     <code type="xml">
 :                         <create-config>
 :
 :                             <!-- create this bucket in an explicit location by passing one of the convenience variables 
 :                                  <code>$const:LOCATION-...</code> defined within the 
 :                                  <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> module -->
 :                             <location>EU</location>
 :
 :                             <!-- grant access control rights by passing one of the convenience variables 
 :                                  <code>$const:ACL-GRANT-...</code> defined within the 
 :                                  <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> module -->
 :                             <acl>public-read</acl>
 :                         </create-config>
 :                     </code> 
 : @param $bucket the name of the bucket to list the contained objects (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare sequential function bucket:create(
    $aws-config as element(aws-config), 
    $create-config as element(create-config)?,
    $bucket as xs:string?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href)
    return 
        block{ 
            (: add location config body and acl header if any :)
            if($create-config)
            then
            (
                if($create-config/location/text()) then
                    let $config := factory:config-create-bucket-location($create-config/location/text()) 
                    let $content := ser:serialize($config)
                    return request:add-content-text($request,$content) 
                else (),
                if($create-config/acl/text()) then 
                    insert node <http:header name="x-amz-acl" value="{$create-config/acl/text()}" /> as first into $request
                else ()
            )
            else ();
   
            s3_request:send($aws-config,$request,$bucket,(:empty object key:)"");
        }
};

(:~
 : Get the access control list (ACL) of a specific bucket. This functions can be used to check granted access
 : rights for this bucket.
 : 
 : Example Response (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <AccessControlPolicy xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Owner>
 :        <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :        <DisplayName>XQuery.me</DisplayName>
 :      </Owner>
 :      <AccessControlList>
 :        <Grant>
 :            <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :                <DisplayName>XQuery.me</DisplayName>
 :            </Grantee>
 :            <Permission>FULL_CONTROL</Permission>
 :        </Grant>
 :      </AccessControlList>
 :   </AccessControlPolicy>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the acl from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an AccessControlPolicy element
:)
declare sequential function bucket:get-config-acl(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="acl" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Get the policy of a specific bucket as JSON string.
 : 
 : Example response (Sequence of two items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/json"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/json"/>
 :   </response>
 :   {
 :     "Version":"2008-10-17",
 :     "Id":"http referer policy example",
 :     "Statement":[
 :       {
 :         "Sid":"Allow get requests referred by www.mysite.com and mysite.com",
 :         "Effect":"Allow",
 :         "Principal":"*",
 :         "Action":"s3:GetObject",
 :         "Resource":"arn:aws:s3:::example-bucket/*",
 :         "Condition":{
 :           "StringLike":{
 :             "aws:Referer":[
 :               " http://www.mysite.com/*",
 :               " http://mysite.com/*"
 :             ]
 :           }
 :         }
 :       }
 :     ]
 :   }
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the policy from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: a JSON string containing the policy data
:)
declare sequential function bucket:get-config-policy(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="policy" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};


(:~
 : Get info where a specific bucket is located. The returned <code>LocationConstraint</code> element might be empty
 : if the location is in the US standard region.
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <LocationConstraint xmlns="http://s3.amazonaws.com/doc/2006-03-01/">EU</LocationConstraint>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the location from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an aws:LocationConstraint element
:)
declare sequential function bucket:get-config-location(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="location" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Get the access logging setting of a specific bucket. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01">
 :      <LoggingEnabled>
 :          <TargetBucket>log-bucket</TargetBucket>
 :          <TargetPrefix>log1/</TargetPrefix>
 :          <TargetGrants>
 :              <Grant>
 :                  <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="AmazonCustomerByEmail">
 :                      <EmailAddress>logreader@example.com</EmailAddress>
 :                  </Grantee>
 :                  <Permission>READ</Permission>
 :              </Grant>
 :          </TargetGrants>
 :      </LoggingEnabled>
 :   </BucketLoggingStatus>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the logging settings from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an s3:BucketLoggingStatus element
:)
declare sequential function bucket:get-config-logging(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="logging" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Get the notification settings of a specific bucket. Notifications are important for reduced redundancy storing to send
 : notifications about an eventually lost update on an object. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <NotificationConfiguration>
 :      <TopicConfiguration>
 :          <Topic>arn:aws:sns:us-east-1:9347298930549283:thelostobjecttopic</Topic>
 :          <Event>s3:ReducedRedundancyLostObject</Event>
 :      </TopicConfiguration>
 :   </NotificationConfiguration>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the notification information from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an NotificationConfiguration element
:)
declare sequential function bucket:get-config-notification(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="notification" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Get request payment configuration of a specific bucket. The configuration defines who pays for transfer fees of objects within 
 : this bucket (could be payed by bucket owner or requester).
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <RequestPaymentConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Payer>Requester</Payer>
 :   </RequestPaymentConfiguration>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the request payment configuration information from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>. 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an s3:RequestPaymentConfiguration element
:)
declare sequential function bucket:get-config-request-payment(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="requestPayment" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Get the versioning configuration of a specific bucket. The returned status may be either <code>Enabled</code>
 : or <code>Suspended</code>. Additionally, an empty <code>s3:VersioningConfiguration</code> element can be returned
 : which means that versioning is suspended (more specifically that it has never been enabled).
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="application/xml"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Status>Enabled</Status>
 :   </VersioningConfiguration>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to get the versioning information from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the main result of this request: an s3:VersioningConfiguration element
:)
declare sequential function bucket:get-config-versioning(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("GET",$href,<parameter name="versioning" />)
    let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
    return 
        $response
};

(:~
 : Grant access permission for a specific bucket to a canonical user or a group of users. This request adds right for users or groups
 : or - if rights exist for those already - replaces existing ones of an access control list (ACL) of a bucket. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <AccessControlPolicy>
 :      <Owner>
 :          <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :          <DisplayName>XQuery.me</DisplayName>
 :      </Owner>
 :      <AccessControlList>
 :          <Grant>
 :              <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                  <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :                  <DisplayName>XQuery.me</DisplayName> 
 :              </Grantee>
 :              <Permission>FULL_CONTROL</Permission>
 :          </Grant>
 :          <Grant>
 :              <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                  <ID>abc084893029362afe39239fe953039d9e2af0c94</ID>
 :                  <DisplayName>Jon</DisplayName> 
 :              </Grantee>
 :              <Permission>FULL_CONTROL</Permission>
 :          </Grant>
 :      </AccessControlList>
 :   </AccessControlPolicy>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to grant an access right for(optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $grantee User/group identifier to grant access rights to. Can be either a unique AWS user id, an email address of an Amazon customer,
 :                 or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>) 
 : @param $permission the permission to be granted to the grantee (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACL-GRANT-...</code>)
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the bucket (contains all granted access rights)
:)
declare sequential function bucket:grant-permission(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $grantee as xs:string,
    $permission as xs:string
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="acl" />)
    return 
        block{
            (: get the current acl of the bucket :)
            declare $access-control-policy := bucket:get-config-acl($aws-config,$bucket)[2];
            
            (: modify policy: add or update grant :)
            let $current-grant := 
                $access-control-policy/AccessControlPolicy/AccessControlList/Grant
                    [Grantee/ID=$grantee or Grantee/DisplayName=$grantee or Grantee/URI=$grantee]
            return
                if($current-grant)
                then
                    replace value of node $current-grant/Permission with $permission
                else insert node 
                        factory:config-grant($grantee,$permission)
                     as last into $access-control-policy/AccessControlPolicy/AccessControlList; 
                
            (: add updated acl config body to the request :)
            s3_request:add-acl-grantee($request,$access-control-policy);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$access-control-policy);
        }
};

(:~
 : Remove a granted access right from a specific bucket for a canonical user or a group of users. This request modifies the existing
 : access control list (ACL) of a bucket. This does not raise an error if no access right has been granted for the user. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <AccessControlPolicy>
 :      <Owner>
 :          <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :          <DisplayName>XQuery.me</DisplayName>
 :      </Owner>
 :      <AccessControlList>
 :          <Grant>
 :              <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                  <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :                  <DisplayName>XQuery.me</DisplayName> 
 :              </Grantee>
 :              <Permission>FULL_CONTROL</Permission>
 :          </Grant>
 :          <Grant>
 :              <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                  <ID>abc084893029362afe39239fe953039d9e2af0c94</ID>
 :                  <DisplayName>Jon</DisplayName> 
 :              </Grantee>
 :              <Permission>FULL_CONTROL</Permission>
 :          </Grant>
 :      </AccessControlList>
 :   </AccessControlPolicy>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to remove the granted access right from (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $grantee User/group identifier to remove the granted access right from. Can be either a unique AWS user id, an email address 
 :                 of an Amazon customer, or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>)
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the bucket (contains all granted access rights)
:)
declare sequential function bucket:remove-permission(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $grantee as xs:string
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="acl" />)
    return 
        block{
            (: get the current acl of the bucket :)
            declare $access-control-policy := bucket:get-config-acl($aws-config,$bucket)[2];
            
            (: modify policy: remove grant :)
            let $current-grant := 
                $access-control-policy/AccessControlPolicy/AccessControlList/Grant
                    [Grantee/ID=grantee or Grantee/DisplayName=grantee or Grantee/URI=grantee]
            return
                if($current-grant)
                then
                    delete node $current-grant
                else (); 
                
            (: add updated acl config body to the request :)
            s3_request:add-acl-grantee($request,$access-control-policy);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$access-control-policy);
        }
};


(:~
 : Set the policy of a bucket. For more details about bucket policies refer to 
 : <a href="http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?UsingBucketPolicies.html" target="_blank">UsingBucketPolicies</a>.
 : The policy is in JSON format and passed to this function as <code>xs:string</code>. 
 : The <a href="http://awspolicygen.s3.amazonaws.com/policygen.html" target="_blank">AWS Policy Generator</a> is 
 : very helpful for generating detailed access policies. 
 : 
 : Example result:
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="204" message="No Content">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to set the policy for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $policy the serialized JSON code representing the policy 
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare sequential function bucket:set-policy(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $policy as xs:string
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="policy" />)
    return 
        block{
            (: add policy config body :)
            request:add-content-text($request,$policy);
            
            s3_request:send($aws-config,$request,$bucket,(:empty object key:)"");
        }
};


(:~
 : This function enables logging for a specific bucket. The logs will be stored in the <code>$logging-bucket</code>
 : or in the monitored <code>$bucket</code> itself if <code>$logging-bucket</code> is empty.
 :
 : You can store the logs of multiple buckets in the same target bucket. In this case, you should provide a <code>$logging-prefix</code>
 : in order to keep the logs distinguishable. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01">
 :      <LoggingEnabled>
 :          <TargetBucket>logging.bucket.example</TargetBucket>
 :          <TargetPrefix>logs-for-bucket-xy/</TargetPrefix>
 :          <TargetGrants>
 :              <Grant>
 :                  <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                      <ID>abc084893029362afe39239fe953039d9e2af0c94</ID>
 :                      <DisplayName>Jon</DisplayName> 
 :                  </Grantee>
 :                  <Permission>READ</Permission>
 :              </Grant>
 :          </TargetGrants>
 :      </LoggingEnabled>
 :   </BucketLoggingStatus>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to enable logging for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $logging-bucket the bucket where the logs will be stored (optional). If no logging bucket is specified the logs
 :                        will be stored in <code>$bucket</code>. 
 : @param $logging-prefix all logs for this bucket will be stored with this prefix (optional) 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the s3:BucketLoggingStatus element that has been set for the bucket logs
:)
declare sequential function bucket:enable-logging(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $logging-bucket as xs:string?,
    $logging-prefix as xs:string?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $logging-bucket as xs:string := if($logging-bucket)then $logging-bucket else $bucket
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="logging" />)
    return 
        block{
            declare $logging-config := factory:config-enable-bucket-logging($logging-bucket, $logging-prefix);
            
            (: add logging config body :)
            request:add-content-xml($request,$logging-config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$logging-config);
        }
};


(:~
 : This function disables logging for a specific bucket. The access logs for <code>$bucket</code> will no longer be stored.
 : This removes also all granted access rights for reading the logs.
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01" />
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to disable logging for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the s3:BucketLoggingStatus element that has been set for the bucket
:)
declare sequential function bucket:disable-logging(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="logging" />)
    return 
        block{
            declare $logging-config := factory:config-disable-bucket-logging();
            
            (: add empty logging config body :)
            request:add-content-xml($request,$logging-config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$logging-config);
        }
};


(:~
 : Grant access rights for logs of a specific bucket either to a canonical user or a group of users. 
 : This request modifies the existing granted permissions of the logs. 
 : 
 : <b>Caution:</b> This function enables logging if it is currently disabled.
 :
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01">
 :      <LoggingEnabled>
 :          <TargetBucket>logging.bucket.example</TargetBucket>
 :          <TargetPrefix>logs-for-bucket-xy/</TargetPrefix>
 :          <TargetGrants>
 :              <Grant>
 :                  <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                      <ID>abc084893029362afe39239fe953039d9e2af0c94</ID>
 :                      <DisplayName>Jon</DisplayName> 
 :                  </Grantee>
 :                  <Permission>READ</Permission>
 :              </Grant>
 :          </TargetGrants>
 :      </LoggingEnabled>
 :   </BucketLoggingStatus>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to grant an access right for all of its logs (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $grantee User/group identifier to grant access rights to. Can be either a unique AWS user id, an email address of an Amazon customer,
 :                 or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>) 
 : @param $permission permission to be granted to the grantee (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACL-GRANT-...</code>)
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the s3:BucketLoggingStatus element that has been set for the bucket logs (contains all granted access rights)
:)
declare sequential function bucket:grant-logging-permission(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $grantee as xs:string,
    $permission as xs:string
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="logging" />)
    return 
        block{
            (: get the current logging config containing all granted permissions of the bucket :)
            declare $logging-config := bucket:get-config-logging($aws-config,$bucket)[2];
            
            (: modify logging config: add or update grant :)
            let $current-grant := 
                $logging-config/s3:BucketLoggingStatus/s3:LoggingEnabled/s3:TargetGrants/s3:Grant
                    [s3:Grantee/s3:ID=$grantee or s3:Grantee/s3:DisplayName=$grantee or s3:Grantee/s3:URI=$grantee]
            return
                if($current-grant)
                then
                    replace value of node $current-grant/s3:Permission with $permission
                else insert node 
                        factory:config-grant($grantee,$permission) 
                     as last into $logging-config/s3:BucketLoggingStatus/s3:LoggingEnabled/s3:TargetGrants; 
                
            (: add logging config body :)
            request:add-content-xml($request,$logging-config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$logging-config);
        }
};


(:~
 : Remove an access right for logs from a specific bucket either from a canonical user or a group of users. 
 : This request modifies the existing granted permissions of the logs. No error is thrown if the permission to 
 : remove does not exist. 
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <BucketLoggingStatus xmlns="http://doc.s3.amazonaws.com/2006-03-01">
 :      <LoggingEnabled>
 :          <TargetBucket>logging.bucket.example</TargetBucket>
 :          <TargetPrefix>logs-for-bucket-xy/</TargetPrefix>
 :          <TargetGrants>
 :              <Grant>
 :                  <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="CanonicalUser">
 :                      <ID>abc084893029362afe39239fe953039d9e2af0c94</ID>
 :                      <DisplayName>Jon</DisplayName> 
 :                  </Grantee>
 :                  <Permission>READ</Permission>
 :              </Grant>
 :          </TargetGrants>
 :      </LoggingEnabled>
 :   </BucketLoggingStatus>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket the name of the bucket to remove an access right from for all of its logs (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $grantee User/group identifier to grant access rights to. Can be either a unique AWS user id, an email address of an Amazon customer,
 :                 or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>) 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the s3:BucketLoggingStatus element that has been set for bucket (contains all granted access rights for the logs)
:)
declare sequential function bucket:remove-logging-permission(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $grantee as xs:string
) as item()* {    

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="logging" />)
    return 
        block{
            (: get the current logging config containing all granted permissions of the bucket :)
            declare $logging-config := bucket:get-config-logging($aws-config,$bucket)[2];
            
            (: if the grantee has been granted an access right remove it :)
            let $current-grant := 
                $logging-config/s3:BucketLoggingStatus/s3:LoggingEnabled/s3:TargetGrants/s3:Grant
                    [s3:Grantee/s3:ID=$grantee or s3:Grantee/s3:DisplayName=$grantee or s3:Grantee/s3:URI=$grantee]
            return
                if($current-grant)
                then
                    delete nodes $current-grant
                else (); 
                
            (: add logging config body :)
            request:add-content-xml($request,$logging-config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$logging-config);
        }
};

(:~
 : This function enables notifications on s3:ReducedRedundancyLostObject events. 
 : Therefore, notification can only be used if the reduced redundancy is turned on. 
 :
 : Please note that AWS will send a notification to the SNS topic to make sure that such a topic 
 : exists. If the passed topic does not exist, you do not have publishing permissions for it, or
 : the topic does not exist in the same region as the bucket, an error:InvalidArgument error is
 : thrown. If the test message was sent successfully the message id will be returned as response
 : header <code>x-amz-sns-test-message-id</code>.
 : 
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-sns-test-message-id" value="aaabbbc-ccdd-3333-5555-eeeeffff0000" />
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <NotificationConfiguration>
 :      <TopicConfiguration>
 :          <Topic>arn:aws:sns:us-east-1:23444322344:lost-object-notification</Topic>
 :          <Event>s3:ReducedRedundancyLostObject</Event>
 :      </TopicConfiguration>
 :   </NotificationConfiguration>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket name of the bucket to enable notifications in the event of a lost object (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $topic the Simple Notification Service (SNS) topic to send the notification to (name starts with "arn:aws:...") 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the NotificationConfiguration element that has been set for a lost object event
:)
declare sequential function bucket:enable-lost-object-notification(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $topic as xs:string
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="notification" />)
    return 
        block{
            declare $config := factory:config-enable-lost-object-notification($topic);
            
            (: add notification config body to request :)
            request:add-content-xml($request,$config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$config);
        }
};


(:~
 : This function disables notifications on s3:ReducedRedundancyLostObject events. 
 :
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <NotificationConfiguration />
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket name of the bucket to disable notifications in the event of a lost object (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the NotificationConfiguration element that has been set for a lost object event. In this case an empty element.
:)
declare sequential function bucket:disable-lost-object-notification(
    $aws-config as element(aws-config),
    $bucket as xs:string?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="notification" />)
    return 
        block{
            declare $config := factory:config-disable-lost-object-notification();
    
            (: add notification config body to request :)
            request:add-content-xml($request,$config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$config);
        }
};


(:~
 : This function lets you configure whether the requester or the owner of a bucket pays for request and 
 : data transfer cost.
 :
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <RequestPaymentConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Payer>Requester</Payer>
 :   </RequestPaymentConfiguration>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket name of bucket to configure the payment settings for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $payer a string defining either the owner of a bucket or the requester (use variables from 
 :               <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> for convenience 
 :               <code>$const:PAYER...</code>) 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the RequestPaymentConfiguration element that has been set for the bucket
:)
declare sequential function bucket:set-request-payment-configuration(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $payer as xs:string
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="requestPayment" />)
    return 
        block{
            declare $config := factory:config-request-payment($payer);
    
            (: add request payment config body to request :)
            request:add-content-xml($request,$config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$config);
        }
};

(:~
 : This function enables versioning for objects contained in the bucket. 
 : 
 : In the same request mfa-deletion can be enabled or disabled. If mfa-delete is set to true objects
 : cannot be deleted permanently any more. If MfaDelete is already enabled or you enabel mfa-delete for the bucket you will not be able to change 
 : versioning settings without the Mfa device.
 :
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Status>Enabled</Status>
 :   </VersioningConfiguration>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket name of bucket to enable versioning for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $mfa-delete if set to true objects within the bucket will not be deleted anymore but only flagged as deleted.
 :                    if you don't know what an MFA-device is set this option to false. Otherwise you won't be able to 
 :                    delete any objects from the bucket any more (optional)  
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the VersioningConfiguration element that has been set for the bucket
:)
declare sequential function bucket:enable-versioning(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $mfa-delete as xs:boolean?
) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="versioning" />)
    return 
        block{
            declare $config := factory:config-enable-versioning($mfa-delete);
    
            (: add versioning config body to request :)
            request:add-content-xml($request,$config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$config);
        }
};

(:~
 : This function disables versioning for objects contained in the bucket. 
 :
 : If MfaDelete is enabled for the bucket you can only change versioning settings with your Mfa device.
 :
 : In the same request mfa-deletion can be enabled or disabled. If mfa-delete is set to true objects
 : cannot be deleted permanently any more. If MfaDelete is already enabled or you enable mfa-delete for 
 : the bucket you will not be able to change versioning settings without the Mfa device.
 :
 : Example result (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 :   <VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
 :      <Status>Suspended</Status>
 :   </VersioningConfiguration>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $bucket name of bucket to disable versioning for (optional). If this name is empty the default 
 :                <code>context-bucket</code> is taken from the <code>$aws-config</code>.
 : @param $mfa-delete if set to true objects within the bucket will not be deleted anymore but only flagged as deleted.
 :                    if you don't know what an MFA-device is set this option to false. Otherwise you won't be able to 
 :                    delete any objects from the bucket any more (optional)  
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the VersioningConfiguration element that has been set for the bucket
:)
declare sequential function bucket:disable-versioning(
    $aws-config as element(aws-config),
    $bucket as xs:string?,
    $mfa-delete as xs:boolean?
 ) as item()* {

    let $bucket as xs:string := if($bucket)then $bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request:href($aws-config, concat($bucket, ".s3.amazonaws.com"))
    let $request := request:create("PUT",$href,<parameter name="versioning" />)
    return 
        block{
            declare $config := factory:config-disable-versioning($mfa-delete);
            
            (: add versioning config body to request :)
            request:add-content-xml($request,$config);
            
            let $response := s3_request:send($aws-config,$request,$bucket,(:empty object key:)"")
            return 
                ($response,$config);
        }
};

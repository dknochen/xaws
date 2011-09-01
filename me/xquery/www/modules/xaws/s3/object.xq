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
module namespace object = 'http://www.xquery.me/modules/xaws/s3/object';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace factory = 'http://www.xquery.me/modules/xaws/s3/factory';
import module namespace request = 'http://www.xquery.me/modules/xaws/s3/request';
import module namespace request_helper = 'http://www.xquery.me/modules/xaws/helpers/request';

declare namespace ann = "http://www.zorba-xquery.com/annotations";


(:~ 
 : Remove an object from a bucket of a user. The user is authenticated with the aws-config. If the bucket is versioned
 : a delete marker is inserted for the object.If mfa-deletion is enabled you will not be able to delete an object without 
 : your MFA device.
 :
 : Example Response (One XML item):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="204" message="NoContent">
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
 : @param $s3-object the s3 object to be deleted. If a version attribute is specified only that version is deleted. 
 :                   Example deleting <code>s3-object</code> elements:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:delete($aws-config,
 :                                       <object:s3-object key="test.xml" 
 :                                                         bucket="{$bucket}" />);
 :                         object:delete($aws-config,
 :                                       <object:s3-object key="test2.xml" 
 :                                                         bucket="{$bucket}" 
 :                                                         version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ" />);
 :
 :                         object:delete($aws-config,
 :                                       factory:s3-object("test.xml","{$bucket}"));
 :                         object:delete($aws-config,
 :                                       factory:s3-object("test2.xml",
 :                                                         "{$bucket}",
 :                                                         "UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first two calls are equivalent to function calls 3 and 4 in the above example. 
 : @return returns the http-response information (header, statuscode,...) 
:)
declare %ann:sequential function object:delete(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $request := if($s3-object/@version)
                    then request_helper:create("DELETE",$href,<parameter name="versionId" value="{$s3-object/@version}" />)
                    else request_helper:create("DELETE",$href)
    return 
        request:send($aws-config,$request,$bucket,$s3-object/@key)
};

(:
 : Read an s3 object. If a version attribute is specified that particular version of the object is fetched.
 :
 : Example Response (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="text/xml"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="ETag" value="fba9dede5f27731c9771645a39863328"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <object:s3-object key="test.xml" 
 :                     bucket="www.xquery.me"
 :                     version="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g">
 :       <object:metadata>
 :           <author>jon</author>
 :       </object:metadata>
 :       <object:content media-type="text/xml">
 :           <data>
 :               <message>Hello World</message>
 :           </data>
 :       </object:content>
 :   </object:s3-object>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to be fetched from S3. If a version attribute is specified only that version is fetched. 
 :                   Example reading <code>s3-object</code> elements:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:read($aws-config,
 :                                     <object:s3-object key="test.xml" 
 :                                                         bucket="{$bucket}" />);
 :                         object:read($aws-config,
 :                                     <object:s3-object key="test2.xml" 
 :                                                         bucket="{$bucket}" 
 :                                                         version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ" />);
 :
 :                         object:read($aws-config,
 :                                     factory:s3-object("test.xml","{$bucket}"));
 :                         object:read($aws-config,
 :                                     factory:s3-object("test2.xml","{$bucket}","UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first two calls are equivalent to function calls 3 and 4 in the above example. 
 : @return returns a pair of 2 items. The first is the http response information (header, statuscode, ...); the second is the 
 :         s3-object containing the data as xml, string (text), or xs:base64Binary.
:)
declare %ann:sequential function object:read(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $request := if($s3-object/@version)
                    then request_helper:create("GET",$href,<parameter name="versionId" value="{$s3-object/@version}" />)
                    else request_helper:create("GET",$href)
    let $response := 1 (: request:send($request) :) (: TODO :)
    let $metadata :=
        <metadata>
        {
            for $header in $response/http:header[starts-with(@name,"x-amz-meta-")]
            let $name := substring-after($header/@name,"x-amz-meta-")
            let $values := tokenize(string($header/@value),",")
            for $value in $values
            return element { $name } { $value }
        }
        </metadata>
    return
        ($response[1],
         factory:s3-object($s3-object/@key,$s3-object/@bucket,$s3-object/@version,$metadata,$response[2]))
};

(:~
 : Get metadata of an s3 object. If a version attribute is specified the metadata of that specific version of the 
 : s3 object is fetched. 
 :
 : This function effectively sends a HEAD http request to s3. If you only wish to get
 : the metadata of an s3 object without retrieving the objects content, then this is the right function to 
 : use. If you want to read both the content of the object AND the metadata, then it is more efficient to
 : use the object:read function. 
 :
 : Example Response (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="text/xml"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="ETag" value="fba9dede5f27731c9771645a39863328"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <object:s3-object key="test.xml" 
 :                     bucket="www.xquery.me"
 :                     version="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g">
 :       <object:metadata>
 :           <author>jon</author>
 :       </object:metadata>
 :   </object:s3-object>
 : </code>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to get the metadata from S3. If a version attribute is specified the metadata of only that version 
 :                   is fetched. Example reading an <code>s3-object</code>'s metadata:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:metadata($aws-config,
 :                                         <object:s3-object key="test.xml" 
 :                                                           bucket="{$bucket}" />);
 :                         object:metadata($aws-config,
 :                                         <object:s3-object key="test2.xml" 
 :                                                           bucket="{$bucket}" 
 :                                                           version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ" />);
 :
 :                         object:metadata($aws-config,
 :                                         factory:s3-object("test.xml","{$bucket}"));
 :                         object:metadata($aws-config,
 :                                         factory:s3-object("test2.xml",
 :                                                           "{$bucket}",
 :                                                           "UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first two calls are equivalent to function calls 3 and 4 in the above example. 
 : @return returns a pair of 2 items. The first is the http response information (header, statuscode, ...); the second is the 
 :         s3-object containing the metadata of that object.
:)
declare %ann:sequential function object:metadata(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $request := if($s3-object/@version)
                    then request_helper:create("HEAD",$href,<parameter name="versionId" value="{$s3-object/@version}" />)
                    else request_helper:create("HEAD",$href)
    let $response := 1 (: request:send($request) :) (: TODO :)
    let $metadata :=
        <metadata>
        {
            for $header in $response/http:header[starts-with(@name,"x-amz-meta-")]
            let $name := substring-after($header/@name,"x-amz-meta-")
            let $values := tokenize(string($header/@value),",")
            for $value in $values
            return element { $name } { $value }
        }
        </metadata>
    return
        ($response[1],
         factory:s3-object($s3-object/@key,$s3-object/@bucket,$s3-object/@version,$metadata,()))
};


(:~
 : Get the torrent information of an object.
 : 
 : Example Response (Sequence of one XML item and one base64 encoded data item):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Disposition" value="attachment; filename=Testfile.torrent;"/>
 :      <header name="Content-Type" value="application/x-bittorrent"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="binary"/>
 :   </response>
 :   ** Here comes some base64 encoded torrent information as defined in the BitTorrent spec **
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to fetch the torrent information for. Example getting an <code>s3-object</code>'s torrent info:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:torrent($aws-config,
 :                                        <object:s3-object key="test" 
 :                                                          bucket="{$bucket}" />);
 :                         object:torrent($aws-config,
 :                                        factory:s3-object("test","{$bucket}"));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                  The first function call is equivalent to the second one in the above example. 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         item is the base64 encoded torrent file of the object
:)
declare %ann:sequential function object:torrent(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $request := request_helper:create("GET",$href,<parameter name="torrent" />)
    return 
      1
    (:
        TODO 
        request:send($request)
    :)
};

(:~
 : upload xml (<code>node()</code> or <code>document-node()</code>), text (<code>xs:string</code>), or binary data 
 : (<code>xs:base64Binary</code>) content into an s3 object. The uploaded object will be marked as "private" which means 
 : it is not publicly accessible. You can use one of the <code>object:permission...</code> functions to change/check access
 : rights.
 :
 : If versioning is turned on the response contains the new object's version id (<code>x-amz-version-id</code>) in the header
 : list.
 :
 : Example Response (One XML item):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="ETag" value="fba9dede5f27731c9771645a39863328"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to write to S3. A version attribute is ignored in this function. 
 :                   Example uploading an <code>s3-object</code>:
 :                     <code type="xquery">
 :                         import module namespace object = 'http://www.xquery.me/modules/xaws/s3/object';
 :                         import module namespace const = 'http://www.xquery.me/modules/xaws/s3/constants';
 :                         import module namespace factory = 'http://www.xquery.me/modules/xaws/s3/factory';
 :                         import module namespace config = 'http://www.xquery.me/modules/xaws/s3/config';
 :
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         variable $s3-object :=
 :                              <object:s3-object key="test.xml" 
 :                                                bucket="www.xquery.me"
 :                                                permisstion="{$const:ACL-GRANT-PUBLIC-READ}">
 :                                  <object:metadata>
 :                                      <author>jon</author>
 :                                  </object:metadata>
 :                                  <object:content media-type="text/xml">
 :                                      <data>
 :                                          <message>Hello World</message>
 :                                      </data>
 :                                  </object:content>
 :                              </object:s3-object>;
 :                         variable $s3-object2 := factory:s3-object(
 :                                                         "test.xml",
 :                                                         "www.xquery.me",
 :                                                         (),
 :                                                         <metadata>
 :                                                             <autor>jon</autor>
 :                                                         </metadata>,
 :                                                         <data>
 :                                                             <message>Hello World</message>
 :                                                         </data>,
 :                                                         $const:ACL-GRANT-PUBLIC-READ);
 :
 :                         object:write($aws-config,$s3-object)
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first variable is equivalent to the second one in the above example. 
 : @param $reduced-redundancy optionally, you can store any data with reduced redundancy to save cost.
 :                            You should do this only for uncritical reproducable data. By default 
 :                            $reduced-redundancy is turned off.
 : @return returns the http reponse data (headers, statuscode,...). The header list contains eventually an x-amz-version-id attribute
 :         if versioning is turned on for the target bucket.
:)
declare %ann:sequential function object:write(
    $aws-config as element(aws-config),
    $s3-object as element(s3-object),
    $reduced-redundancy as xs:boolean?
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $headers := (
            (: TODO add content lenght and content md5 :)
            if($reduced-redundancy) then <header name="x-amz-storage-class" value="REDUCED_REDUNDANCY" /> else (),
            if($s3-object/@permission) then <header name="x-amz-acl" value="{string($s3-object/@permission)}" /> else (),
            for $meta in $s3-object/object:metadata/node()
            let $name := concat("x-amz-meta-",$meta/local-name())
            let $value := string($meta/text())
            return <http:header name="{$name}" value="{$value}" />
        )
    
    (: default is binary :)
    let $media-type := ($s3-object/object:content/@media-type,"binary/octet-stream")[1] 
    let $serialize-method := ($s3-object/object:content/@method,"binary")[1]
    let $content := $s3-object/object:content/node()
    
    let $request := request_helper:create("PUT",$href,()(:no parameters:), $headers, $media-type, $serialize-method, $content)
    return 
      1
      (: TODO
       request:send($request)[1]
       :)
};

(:~
 : Get the access control list (ACL) of an S3 object or even of an particular version of an object. The ACL is 
 : a list containing all granted permission for users or user groups. All available access rights can be found in the 
 : <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> module (variables starting 
 : with <code>$const:ACL-GRANT-...</code>.
 :
 : Example Response (Sequence of two XML items):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Content-Type" value="text/xml"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="ETag" value="fba9dede5f27731c9771645a39863328"/>
 :      <header name="Transfer-Encoding" value="chunked"/>
 :      <header name="Server" value="AmazonS3"/>
 :      <body media-type="application/xml"/>
 :   </response>
 :   <AccessControlPolicy>
 :      <Owner>
 :          <ID>dfe08489302934392afe39239fe953039d9e2af0c94</ID>
 :          <DisplayName>XQuery.me</DisplayName>
 :      </Owner>
 :      <AccessControlList>
 :          <Grant>
 :              <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 :                       xsi:type="CanonicalUser">
 :                  <ID>8a6925ce4adf588a453214a379004fef</ID>
 :                  <DisplayName>mtd@amazon.com</DisplayName>
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
 : @param $s3-object the s3 object to fetch the S3 ACL for. If a version attribute is specified the ACL specific to that version 
 :                   is fetched. Example getting an <code>s3-object</code>'s ACL:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:permissions($aws-config,
 :                                            <object:s3-object key="test.xml" 
 :                                                              bucket="{$bucket}" />);
 :                         object:permissions($aws-config,
 :                                            <object:s3-object key="test2.xml" 
 :                                                              bucket="{$bucket}" 
 :                                                              version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ" />);
 :
 :                         object:permissions($aws-config,
 :                                            factory:s3-object("test.xml","{$bucket}"));
 :                         object:permissions($aws-config,
 :                                            factory:s3-object("test2.xml","{$bucket}","UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first two calls are equivalent to function calls 3 and 4 in the above example. 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is an AccessControlPolicy element
:)
declare %ann:sequential function object:permissions(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $parameters := (if($s3-object/@version)
                        then <parameter name="versionId" value="{$s3-object/@version}" /> else (),
                        <parameter name="acl" />)
    let $request := request_helper:create("GET",$href,$parameters)
    return 
      1
      (: TODO
        request:send($request)
      :)
};

(:~
 : Set access rights of an object for everybody. This request eventually replaces the existing
 : access control list (ACL) of this object. 
 : 
 : If versioning is enabled for that object and no version attribut is given this functions will set permissions 
 : for the latest version of the object. If a version attribute is present only the permission for that particular
 : version of the object will be set. 
 : 
 : To set a permission to everybody the <code>$const:ACL-GRANT-...</code> variables from the 
 : <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> module can be used for
 : convenience.
 :
 : Example Response (One XML item):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to set the S3 ACL for. If a version attribute is specified the ACL specific to that version 
 :                   is put. Example setting an <code>s3-object</code>'s ACL:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:permission-set($aws-config,
 :                                               <object:s3-object key="test.xml" 
 :                                                                 bucket="{$bucket}" 
 :                                                                 permisstion="{$const:ACL-GRANT-PUBLIC-READ}" />);
 :                         object:permission-set($aws-config,
 :                                               <object:s3-object key="test2.xml" 
 :                                                                 bucket="{$bucket}" 
 :                                                                 version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"
 :                                                                 permisstion="{$const:ACL-GRANT-PUBLIC-READ}" />);
 :
 :                         object:permission-set($aws-config,
 :                                               factory:s3-object("test.xml",
 :                                                                 "{$bucket}", 
 :                                                                 (), 
 :                                                                 $const:ACL-GRANT-PUBLIC-READ));
 :                         object:permission-set($aws-config,
 :                                               factory:s3-object("test2.xml",
 :                                                                 "{$bucket}",
 :                                                                 "UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ",
 :                                                                 $const:ACL-GRANT-PUBLIC-READ));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 :                   The first two calls are equivalent to function calls 3 and 4 in the above example. 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the object (contains all granted access rights)
:)
(: TODO this needs to be tested. I don't think that it works this way
        also the example is not correct: two items should be returned :)
declare %ann:sequential function object:permission-set(
    $aws-config as element(aws-config),
    $s3-object as element(object:s3-object)
) as item()* {    

    let $bucket as xs:string := if($s3-object/@bucket)then $s3-object/@bucket else string($aws-config/context-bucket/text())
    let $href as xs:string := request_helper:href($aws-config, concat($bucket, ".s3.amazonaws.com/",$s3-object/@key))
    let $parameters := (if($s3-object/@version)
                        then <parameter name="versionId" value="{$s3-object/@version}" /> else (),
                        <parameter name="acl" />)
    let $acl :=
        <AccessControlPolicy>
            <!--<Owner>
                <ID>8a6925ce4adf588e97f21c32aa379004fef</ID>
                <DisplayName>CustomersName@amazon.com</DisplayName>
            </Owner>-->
            <AccessControlList>
                <Grant>
                    <Grantee xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xsi:type="Group">
                        <URI>http://acs.amazonaws.com/groups/global/AuthenticatedUsers</URI>
                    </Grantee>
                    <Permission>{string($s3-object/@permission)}</Permission>
                </Grant>
            </AccessControlList>
        </AccessControlPolicy>
    let $request := request_helper:create("PUT",$href,$parameters,()(:no headers:),"application/xml","xml",$acl)
    return 
      (: TODO
        (request:send($request)[1], $acl)
      :)
      1
};

(:~
 : grant access rights to an object for a canonical user or a group of users. This request modifies the existing
 : access control list (ACL) of an object.
 : 
 : If versioning is enabled for that object and no version attribut is given this functions will set permissions 
 : for the latest version of the object. If a version attribute is present only the permission for that particular
 : version of the object will be set. 
 : 
 : To set a permission to everybody the <code>$const:ACL-GRANT-...</code> variables from the 
 : <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> module can be used for
 : convenience.
 :
 : Example Response (One XML item):
 : <code type="xml">
 :   <response xmlns="http://expath.org/ns/http-client" status="200" message="OK">
 :      <header name="x-amz-id-2" value="dXV0GmxfZ5JoT9UMDYd6oeyxLcPI6cd7b7dLGD4RyDib4Km/OTlwkzL5EsM79Q"/>
 :      <header name="x-amz-request-id" value="41FF3227D3514733"/>
 :      <header name="x-amz-version-id" value="3GL4kqtJlcpXroDTDm3vjVBH40Nr8X8g"/>
 :      <header name="Date" value="Mon, 11 Apr 2011 19:38:26 GMT"/>
 :      <header name="Last-Modified" value="Mon, 11 Apr 2011 20:08:26 GMT"/>
 :      <header name="Server" value="AmazonS3"/>
 :   </response>
 : </code>
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $s3-object the s3 object to set the S3 ACL for. If a version attribute is specified the ACL specific to that version 
 :                   is put. Example setting an <code>s3-object</code>'s ACL:
 :                     <code type="xquery">
 :                         variable $aws-config := config:create("aws-key","aws-secret");
 :                         object:permission-set($aws-config,
 :                                               <object:s3-object key="test.xml" 
 :                                                                 bucket="{$bucket}" 
 :                                                                 permisstion="{$const:ACL-GRANT-PUBLIC-READ}" />);
 :                         object:permission-set($aws-config,
 :                                               <object:s3-object key="test2.xml" 
 :                                                                 bucket="{$bucket}" 
 :                                                                 version="UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ"
 :                                                                 permisstion="{$const:ACL-GRANT-PUBLIC-READ}" />);
 :
 :                         object:permission-set($aws-config,
 :                                               factory:s3-object("test.xml",
 :                                                                 "{$bucket}", 
 :                                                                 (), 
 :                                                                 $const:ACL-GRANT-PUBLIC-READ));
 :                         object:permission-set($aws-config,
 :                                               factory:s3-object("test2.xml",
 :                                                                 "{$bucket}",
 :                                                                 "UIORUnfndfiufdisojhr398493jfdkjFJjkndnqUifhnw89493jJFJ",
 :                                                                 $const:ACL-GRANT-PUBLIC-READ));
 :                     </code> 
 :                   The example above shows how an s3-object element can conveniently be referenced using the <code>s3-object</code>
 :                   functions from the <a href="http://www.xquery.me/modules/xaws/s3/factory">factory</a> module.
 : @param $grantee User/group identifier to grant access rights to. Can be either a unique AWS user id, an email address of an Amazon customer,
 :                 or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a> 
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>) 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the object (contains all granted access rights)
:)
(: TODO this needs to be tested. I don't think that it works this way :)
declare %ann:sequential function object:grant-permission(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $bucket as xs:string,
    $key as xs:string,
    $grantee as xs:string,
    $permission as xs:string
) as item()* {    

    let $href as xs:string := concat("http://", $bucket, ".s3.amazonaws.com/", $key)
    let $request := request_helper:create("PUT",$href,<parameter name="acl" />)
    return 
      {
            (: get the current acl of the object :)
            variable $access-control-policy := 1; (: TODO object:get-config-acl($aws-access-key,$aws-secret,$bucket,$key); :)
            
            (: modify policy: add or update grant :)
            let $current-grant := 
                $access-control-policy/AccessControlPolicy/AccessControlList/Grant
                    [Grantee/ID=$grantee or Grantee/DisplayName=$grantee or Grantee/URI=$grantee]
            return
                if($current-grant)
                then
                    replace value of node $current-grant/Permission with $permission;
                else insert node 
                        factory:config-grant($grantee,$permission) 
                     as last into $access-control-policy/AccessControlPolicy/AccessControlList; 
                
            (: add acl config body :)
            request:add-acl-grantee($request,$access-control-policy);
            
            (: sign the request :)
            request:sign(
                $request,
                $bucket,
                $key,
                $aws-access-key,
                $aws-secret);
                
            (:request_helper:send($request),$access-control-policy) :)
     }
};





(:~
 : Remove a granted access right from a specific object for a canonical user or a group of users. This request modifies the existing
 : access control list (ACL) of an object. 
 : 
 : If versioning is enabled for the object this functions removes a permission from the latest version of the object. 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $bucket the name of the bucket in which the object resides to remove the granted access right from
 : @param $key the key of the object to remove a permission from
 : @param $grantee User/group identifier to remove the granted access right from. Can be either a unique AWS user id, an email address 
 :                 of an Amazon customer, or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>)
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the bucket (contains all granted access rights)
:)
declare %ann:sequential function object:remove-permission(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $bucket as xs:string,
    $key as xs:string,
    $grantee as xs:string
) as item()* {    

    let $href as xs:string := concat("http://", $bucket, ".s3.amazonaws.com/",$key)
    let $request := request_helper:create("PUT",$href,<parameter name="acl" />)
    return 
      {
            (: get the current acl of the object :)
            variable $access-control-policy := 1 (: TODO object:get-config-acl($aws-access-key,$aws-secret,$bucket,$key); :);
            
            (: modify policy: remove grant :)
            let $current-grant := 
                $access-control-policy/AccessControlPolicy/AccessControlList/Grant
                    [Grantee/ID=grantee or Grantee/DisplayName=grantee or Grantee/URI=grantee]
            return
                if($current-grant)
                then
                    delete node $current-grant;
                else (); 
                
            (: add acl config body :)
            request:add-acl-grantee($request,$access-control-policy);
            
            (: sign the request :)
            request:sign(
                $request,
                $bucket,
                $key,
                $aws-access-key,
                $aws-secret);
                
            (: TODO request:send($request),$access-control-policy:)
      }
};


(:~
 : Remove a granted access right from a specific object for a canonical user or a group of users. This request modifies the existing
 : access control list (ACL) of an object. 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $bucket the name of the bucket in which the object resides to remove the granted access right from
 : @param $key the key of the object to remove a permission from
 : @param $grantee User/group identifier to remove the granted access right from. Can be either a unique AWS user id, an email address 
 :                 of an Amazon customer, or a user group identified by a uri (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACS-GROUPS...</code>)
 : @param $version-id the version id of the object to delete 
 : @return returns a pair of two items, the first is the http reponse data (headers, statuscode,...), the second
 :         is the AccessControlPolicy element that has been set for the bucket (contains all granted access rights)
:)
declare %ann:sequential function object:remove-permission(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $bucket as xs:string,
    $key as xs:string,
    $grantee as xs:string,
    $version-id as xs:string
) as item()* {    

    let $href as xs:string := concat("http://", $bucket, ".s3.amazonaws.com/",$key)
    let $request := request_helper:create(
                                    "PUT",
                                    $href,
                                    (<parameter name="acl" />,<parameter name="versionId" value="{$version-id}" />)
                                  )
    return 
      {
            (: get the current acl of the object version :)
            variable $access-control-policy := 1 (: TODO object:get-config-acl($aws-access-key,$aws-secret,$bucket,$key,$version-id); :);
            
            (: modify policy: remove grant :)
            let $current-grant := 
                $access-control-policy/AccessControlPolicy/AccessControlList/Grant
                    [Grantee/ID=grantee or Grantee/DisplayName=grantee or Grantee/URI=grantee]
            return
                if($current-grant)
                then
                    delete node $current-grant;
                else (); 
                
            (: add acl config body :)
            request:add-acl-grantee($request,$access-control-policy);
            
            (: sign the request :)
            request:sign(
                $request,
                $bucket,
                $key,
                $aws-access-key,
                $aws-secret);
                
            (:request:send($request),$access-control-policy:)
      }
};

(:~
 : Copy an object that is already stored on s3 into a different object in the same bucket in which the source object resides. 
 : The access rights of the source object are not copied with this function. By default, this function sets the target object 
 : access right to private. 
 : 
 : If versioning is enabled for that object this functions copies the latest version of the object. 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $bucket the name of the bucket from which an object is to be copied and into that the target object is written
 : @param $source-key the key of the object to copy from
 : @param $target-key the key of the object to copy to
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare %ann:sequential function object:copy(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $bucket as xs:string,
    $source-key as xs:string,
    $target-key as xs:string
) as item()* {    
    object:copy(
        $aws-access-key, 
        $aws-secret,
        $bucket,
        $source-key,
        $bucket,
        $target-key,
        (),
        (),
        ()
    )
};

(:~
 : Copy an object that is already stored on s3 into a target bucket. The access rights of the source object are
 : not copied with this function. By default, this function sets the target object access right to private. 
 : 
 : If versioning is enabled for that object this functions copies the latest version of the object. 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $source-bucket the name of the bucket from which an object is to be copied
 : @param $source-key the key of the object to copy from
 : @param $target-bucket the name of the bucket to copy the source-object to
 : @param $target-key the key of the object to copy to
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare %ann:sequential function object:copy(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $source-bucket as xs:string,
    $source-key as xs:string,
    $target-bucket as xs:string,
    $target-key as xs:string
) as item()* {    
    object:copy(
        $aws-access-key, 
        $aws-secret,
        $source-bucket,
        $source-key,
        $target-bucket,
        $target-key,
        (),
        (),
        ()
    )
};

(:~
 : Copy an object that is already stored on s3 into a target bucket. The access rights of the source object are
 : not copied with this function. By default, this function sets the target object access right to private. 
 : 
 : If versioning is enabled for that object this functions copies the latest version of the object. 
 : 
 : Additionaly, you can provide any metadata to replace the source object's metadata with in the target object. For example:
 :
 : <pre>
 :   <code>
 :   <![CDATA[
 : <metadata>
 :    <author>Jon</author>
 :    <author>Jane</author>
 :    <category>XQuery</category>
 : </metadata>
 :   ]]>
 :   </code>
 : </pre>
 : 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $source-bucket the name of the bucket from which an object is to be copied
 : @param $source-key the key of the object to copy from
 : @param $target-bucket the name of the bucket to copy the source-object to
 : @param $target-key the key of the object to copy to
 : @param $acl the permission to be granted to everybody (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACL-GRANT-...</code>) for the target object
 : @param $metadata optionally, you can provide any custom metadata to the target object of the copy function. If $metadata parameter
 :                  is an empty sequence then the source object's metadata is copied. In order to simply replace the source object metadata
 :                  with no metadata pass an empty <code>&lt;metadata /></code> element
 : @param $reduced-redundancy optionally, you can store any data with reduced redundancy to save cost.
 :                            You should do this only for uncritical reproducable data. Per default 
 :                            $reduced-redundancy is turned off.
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare %ann:sequential function object:copy(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $source-bucket as xs:string,
    $source-key as xs:string,
    $target-bucket as xs:string,
    $target-key as xs:string,
    $acl as xs:string?,
    $metadata as element(metadata)?,
    $reduced-redundancy as xs:boolean?
) as item()* {    

    object:copy(
        $aws-access-key, 
        $aws-secret,
        $source-bucket,
        $source-key,
        $target-bucket,
        $target-key,
        (),
        (),
        (),
        ()
    )
};


(:~
 : Copy a specific version of an object that is already stored on s3 into a target bucket. The access rights of the source object are
 : not copied with this function. By default, this function sets the target object access right to private. 
 : 
 : Additionaly, you can provide any metadata to replace the source object's metadata with in the target object. For example:
 :
 : <pre>
 :   <code>
 :   <![CDATA[
 : <metadata>
 :    <author>Jon</author>
 :    <author>Jane</author>
 :    <category>XQuery</category>
 : </metadata>
 :   ]]>
 :   </code>
 : </pre>
 : 
 : 
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $source-bucket the name of the bucket from which an object is to be copied
 : @param $source-key the key of the object to copy from
 : @param $target-bucket the name of the bucket to copy the source-object to
 : @param $target-key the key of the object to copy to
 : @param $acl the permission to be granted to everybody (see <a href="http://www.xquery.me/modules/xaws/s3/constants">constants</a>
 :                 for convenience variables <code>$const:ACL-GRANT-...</code>) for the target object
 : @param $metadata optionally, you can provide any custom metadata to the target object of the copy function. If $metadata parameter
 :                  is an empty sequence then the source object's metadata is copied. In order to simply replace the source object metadata
 :                  with no metadata pass an empty <code>&lt;metadata /></code> element
 : @param $reduced-redundancy optionally, you can store any data with reduced redundancy to save cost.
 :                            You should do this only for uncritical reproducable data. Per default 
 :                            $reduced-redundancy is turned off.
 : @param $version-id the version id of the source object to be copied 
 : @return returns the http reponse data (headers, statuscode,...)
:)
declare %ann:sequential function object:copy(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $source-bucket as xs:string,
    $source-key as xs:string,
    $target-bucket as xs:string,
    $target-key as xs:string,
    $acl as xs:string?,
    $metadata as element(metadata)?,
    $reduced-redundancy as xs:boolean?,
    $version-id as xs:string?
) as item()* {    

    let $href as xs:string := concat("http://", $target-bucket, ".s3.amazonaws.com/", $target-key)
    let $request := 
        if ($version-id) 
        then
            request_helper:create("PUT",$href,<parameter name="versionId" value="{$version-id}" />)
        else
            request_helper:create("PUT",$href)
    return 
      {
            (: TODO
                request:add-acl-everybody($request,$acl),
                request:add-metadata($request,$metadata/*),
                request:add-copy-source($request,$source-bucket,$source-key),
                if($metadata) then request:add-replace-metadata-flag($request) else (),
                if($reduced-redundancy)then  TODO request:add-reduced-redundancy($request) else ()
            );
            :)
                
            (: sign the request :)
            request:sign(
                $request,
                $target-bucket,
                $target-key,
                $aws-access-key,
                $aws-secret);
                
            (: TODO request:send($request) :)
     }
};

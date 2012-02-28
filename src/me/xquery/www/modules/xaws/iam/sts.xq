(:
 : Copyright 2012 XQuery.me
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
 :      This Module provides functions to interact with the Amazon Security Token Service (STS)
 :      
 :      The AWS Security Token Service is a web service that enables you to request temporary, 
 :      limited-privilege credentials for AWS Identity and Access Management (IAM) users or for users 
 :      that you authenticate (federated users). 
 : 
 : </p>
 : 
 : @author Alexander Kreutz alexander [dot] kreutz [at] 28msec [dot] com
:)
module namespace sts = 'http://www.xquery.me/modules/xaws/iam/sts';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace iam_request = 'http://www.xquery.me/modules/xaws/iam/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/iam/error';

declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : The GetFederationToken action returns a set of temporary credentials for a federated user with the user name 
 : and policy specified in the request. 
 : The credentials consist of an Access Key ID, a Secret Access Key, and a security token. 
 : Credentials created by IAM users are valid for the specified duration, between one and 36 hours; 
 : credentials created using account credentials last one hour.
 :
 : The federated user who holds these credentials has any permissions allowed by the intersection of the specified 
 : policy and any resource or user policies that apply to the caller of the GetFederationToken API, and any resource 
 : policies that apply to the federated user's Amazon Resource Name (ARN). 
 : Adds (or updates) a policy document associated with the specified group.  
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace sts = "http://www.xquery.me/modules/xaws/iam/sts";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $name := "Client"     
 :   let $policy := '{"Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}'
 :   let $durationSeconds := 3600 
 :   return 
 :     sts:getFederationToken($aws-config, $name, $policy, $durationSeconds)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $name The name of the federated user associated with the credentials. For information about limitations on user names, go to Limitations on IAM Entities in Using AWS Identity and Access Management.
 : @param $policy A policy specifying the permissions to associate with the credentials. The caller can delegate their own permissions by specifying a policy, and both policies will be checked when a service call is made.
 : @param $durationSeconds The duration, in seconds, that the session should last. Acceptable durations for federation sessions range from 3600s (one hour) to 129600s (36 hours), with 43200s (12 hours) as the default. 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetFederationTokenResult element 
:)
declare %ann:sequential function sts:getFederationToken(
    $aws-config as element(aws-config),
    $name as xs:string,    
    $policy as xs:string?,
    $durationSeconds as xs:integer?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "sts.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetFederationToken" />,       
      <parameter name="Name" value="{$name}" />,
      utils:if-then($policy, <parameter name="Policy" value="{$policy}" />),
      utils:if-then($durationSeconds, <parameter name="DurationSeconds" value="{$durationSeconds}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send-sts($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : The GetSessionToken action returns a set of temporary credentials for an AWS account or IAM user. 
 : The credentials consist of an Access Key ID, a Secret Access Key, and a security token. 
 : These credentials are valid for the specified duration only. 
 : The session duration for IAM users can be between one and 36 hours, with a default of 12 hours. 
 : The session duration for AWS account owners is restricted to one hour.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace sts = "http://www.xquery.me/modules/xaws/iam/sts";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 ::  
 :   let $durationSeconds := 3600 
 :   return 
 :     sts:getSessionToken($aws-config, $durationSeconds)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $name The name of the federated user associated with the credentials. For information about limitations on user names, go to Limitations on IAM Entities in Using AWS Identity and Access Management.
 : @param $policy A policy specifying the permissions to associate with the credentials. The caller can delegate their own permissions by specifying a policy, and both policies will be checked when a service call is made.
 : @param $durationSeconds The duration, in seconds, that the session should last. Acceptable durations for federation sessions range from 3600s (one hour) to 129600s (36 hours), with 43200s (12 hours) as the default. 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetSessionTokenResult element 
:)
declare %ann:sequential function sts:getSessionToken(
    $aws-config as element(aws-config),    
    $durationSeconds as xs:integer?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "sts.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetSessionToken" />,            
      utils:if-then($durationSeconds, <parameter name="DurationSeconds" value="{$durationSeconds}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send-sts($aws-config,$request,$parameters)
  return 
    $response

};
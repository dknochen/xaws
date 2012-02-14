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
 :      This Module provides functions to interact with the Amazon Simple 
 :      Notification Service (SNS).
 :      
 :      Amazon SNS is a highly available and scalable webservice that 
 :      provides functions to submit messages to subscribers via http or
 :      email.
 :      The developer could create a topic, which can be subscribed by 
 :      users or applications to receive the notifications.
 : </p>
 : 
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace user = 'http://www.xquery.me/modules/xaws/iam/user';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace iam_request = 'http://www.xquery.me/modules/xaws/iam/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/iam/error';

declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : create a new user
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $user := 
 :     <User>
 :       <Path>/division_abc/subdivision_xyz/</Path>
 :       <UserName>Bob</UserName>
 :     </User>
 :   return 
 :     user:create($aws-config, $user)
 : </code>
 :
 : The Path element is optional. 
 :
 : "If you are using the API or command line interface to create users, you can also optionally give 
 : the entity a path that you define. You might use the path to identify which division or part of the 
 : organization the entity belongs in. For example: /division_abc/subdivision_xyz/product_1234/engineering/. 
 : [...] Just because you give a user and group the same path doesn't automatically put that user in that 
 : group." (source: <a href="http://docs.amazonwebservices.com/IAM/latest/UserGuide/Using_Identifiers.html#Identifiers_FriendlyNames">
 : AWS Documentation: IAM User Guide: Friendly Names and Paths</a>)
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $user The user to be created
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the CreateUserResponse element 
:)
declare %ann:sequential function user:create(
    $aws-config as element(aws-config),
    $user as element(User)
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="CreateUser" />, 
      <parameter name="UserName" value="{$user/UserName/text()}" />,
      utils:if-then ($user/Path,
        <parameter name="Path" value="{$user/Path/text()}" />)  
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response
    
};

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
 :      This Module provides functions to interact with the Amazon IAM API
 :      
 :      IAM is a web service that enables AWS customers to manage users and user permissions
 :      under their AWS account.
 : 
 : </p>
 : 
 : @author Alexander Kreutz alexander [dot] kreutz [at] 28msec [dot] com
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
 :     user:createUser($aws-config, $user)
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
declare %ann:sequential function user:createUser(
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

(:~
 : adds a user to a group
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob" 
 :   let $groupName := "Clients"
 :   return 
 :     user:addUserToGroup($aws-config, $userName, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName The name of the user to be added to a group
 : @param $groupName the name of the group the user should be added to
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the AddUserToGroupResponse element 
:)
declare %ann:sequential function user:addUserToGroup(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $groupName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="AddUserToGroup" />, 
      <parameter name="GroupName" value="{$groupName}" />,
      <parameter name="UserName" value="{$userName}" />  
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Creates a new AWS Secret Access Key and corresponding AWS Access Key ID for the specified user. 
 : The default status for new keys is Active.
 :
 : If you do not specify a user name, IAM determines the user name implicitly based on the AWS Access Key ID signing the request. 
 : Because this action works for access keys under the AWS account, you can use this API to manage root credentials even if the AWS account has no associated users.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"     
 :   return 
 :     user:createAccessKey($aws-config, $userName, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName The user name that the new key will belong to. (Optional) 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the CreateAccessKeyResult element 
:)
declare %ann:sequential function user:createAccessKey(
    $aws-config as element(aws-config),
    $userName as xs:string?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="CreateAccessKey" />,       
      utils:if-then($userName, <parameter name="UserName" value="{$userName}" />)  
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : This action creates an alias for your AWS account.
 : 
 : For information about using an AWS account alias, see Using an Alias for Your AWS Account ID in Using AWS Identity and Access Management.
 : 
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $accountAlias := "MyAlias"     
 :   return 
 :     user:createAccountAlias($aws-config, $accountAlias)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $accountAlias Name of the account alias to create. (Length constraints: Minimum value of 3. Maximum value of 63)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the CreateAccountAliasResponse element 
:)
declare %ann:sequential function user:createAccountAlias(
    $aws-config as element(aws-config),
    $accountAlias as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="CreateAccountAlias" />,       
      <parameter name="AccountAlias" value="{$accountAlias}" />  
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Creates a new group.
 : 
 : 
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $group := 
 :     <Group>
 :       <Path>/division_abc/subdivision_xyz/</Path>
 :       <GroupName>Clients</GroupName>
 :     </Group>
 :   return 
 :     user:createGroup($aws-config, $user)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $accountAlias Name of the account alias to create. (Length constraints: Minimum value of 3. Maximum value of 63)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the CreateGroupResult element 
:)
declare %ann:sequential function user:createGroup(
    $aws-config as element(aws-config),
    $group as element(Group)
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="CreateGroup" />,       
      <parameter name="GroupName" value="{$group/GroupName/text()}" />,
      utils:if-then ($group/Path, <parameter name="Path" value="{$group/Path/text()}" />)  
        
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Creates a login profile for the specified user, giving the user the ability to access AWS services such as the AWS Management Console.
 : 
 : For more information about login profiles, see Creating or Deleting a User Login Profile in Using AWS Identity and Access Management.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob" 
     let $password := "Password123"
 :   return 
 :     user:createLoginProfile($aws-config, $user, $password)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to create a login profile for.
 : @param $password The new password for the user name. (Length constraints: Minimum value of 1. Maximum value of 128)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the CreateLoginProfileResult element 
:)
declare %ann:sequential function user:createLoginProfile(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $password as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="CreateLoginProfile" />,       
      <parameter name="UserName" value="{$userName}" />,
      <parameter name="Password" value="{$password}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};


(:~
 : Deletes the access key associated with the specified user.
 :
 : If you do not specify a user name, IAM determines the user name implicitly based on the AWS Access Key ID signing the request.
 : Because this action works for access keys under the AWS account, you can use this API to manage root credentials even if the AWS account has no associated users.
 : 
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $accessKeyId := "ABCDEFGHIJKLMNOPQRSTU" 
     let $userName := "Bob"
 :   return 
 :     user:deleteAccessKey($aws-config, $accessKeyId, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $accessKeyId The Access Key ID for the Access Key ID and Secret Access Key you want to delete.
 : @param $userName Name of the user whose key you want to delete. (Optional)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteAccessKeyResponse element 
:)
declare %ann:sequential function user:deleteAccessKey(
    $aws-config as element(aws-config),
    $accessKeyId as xs:string,
    $userName as xs:string?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteAccessKey" />,       
      <parameter name="AccessKeyId" value="{$accessKeyId}" />,
      utils:if-then($userName, <parameter name="UserName" value="{$userName}" />)               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Deletes the specified AWS account alias. For information about using an AWS account alias, see Using an Alias for Your AWS Account ID in Using AWS Identity and Access Management. 
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $accountAlias := "MyAlias"      
 :   return 
 :     user:deleteAccountAlias($aws-config, $accountAlias)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $accountAlias Name of the account alias to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteAccountAliasResponse element 
:)
declare %ann:sequential function user:deleteAccountAlias(
    $aws-config as element(aws-config),
    $accountAlias as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteAccountAlias" />,       
      <parameter name="AccountAlias" value="{$accountAlias}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Deletes the specified group. The group must not contain any users or have any attached policies.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"      
 :   return 
 :     user:deleteGroup($aws-config, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteGroupResponse element 
:)
declare %ann:sequential function user:deleteGroup(
    $aws-config as element(aws-config),
    $groupName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteGroup" />,       
      <parameter name="GroupName" value="{$groupName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Deletes the login profile for the specified user, which terminates the user's ability to access AWS services through the IAM login page.
 :
 : Deleting a user's login profile does not prevent a user from accessing IAM through the command line interface or the API. 
 : To prevent all user access you must also either make the access key inactive or delete it. For more information about making keys inactive or deleting them, see UpdateAccessKey and DeleteAccessKey. 
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"      
 :   return 
 :     user:deleteLoginProfile($aws-config, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user whose login profile you want to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteLoginProfileResponse element 
:)
declare %ann:sequential function user:deleteLoginProfile(
    $aws-config as element(aws-config),
    $userName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteLoginProfile" />,       
      <parameter name="UserName" value="{$userName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Deletes the specified user. The user must not belong to any groups, have any keys or signing certificates, or have any attached policies.
 :
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"      
 :   return 
 :     user:deleteUser($aws-config, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteUserResponse element 
:)
declare %ann:sequential function user:deleteUser(
    $aws-config as element(aws-config),
    $userName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteUser" />,       
      <parameter name="UserName" value="{$userName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Returns a list of users that are in the specified group. This version of getGroup does not use pagination. 
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"      
 :   return 
 :     user:getGroup($aws-config, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetGroupResult element 
:)
declare %ann:sequential function user:getGroup(
    $aws-config as element(aws-config),
    $groupName as xs:string      
) as item()* {
  user:getGroup($aws-config, $groupName, () ,());
};

(:~
 : Returns a list of users that are in the specified group. You can paginate the results using the MaxItems parameters.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"      
 :   return 
 :     user:getGroup($aws-config, $groupName, ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of user names you want in the response. If there are additional user names beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetGroupResult element 
:)
declare %ann:sequential function user:getGroup(
    $aws-config as element(aws-config),
    $groupName as xs:string,    
    $maxItems as xs:integer?
) as item()* {
  user:getGroup($aws-config, $groupName, () ,$maxItems);
};
(:~
 : Returns a list of users that are in the specified group. You can paginate the results using the MaxItems and Marker parameters.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"      
 :   return 
 :     user:getGroup($aws-config, $groupName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of user names you want in the response. If there are additional user names beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetGroupResult element 
:)
declare %ann:sequential function user:getGroup(
    $aws-config as element(aws-config),
    $groupName as xs:string,
    $marker as xs:string?,
    $maxItems as xs:integer?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetGroup" />,       
      <parameter name="GroupName" value="{$groupName}" />,
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Retrieves the login profile for the specified user.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"      
 :   return 
 :     user:getLoginProfile($aws-config, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user whose login profile you want to retrieve.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetLoginProfileResult element 
:)
declare %ann:sequential function user:getLoginProfile(
    $aws-config as element(aws-config),
    $userName as xs:string    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetLoginProfile" />,       
      <parameter name="UserName" value="{$userName}" />      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Retrieves information about the specified user, including the user's path, GUID, and ARN.
 :
 : If you do not specify a user name, IAM determines the user name implicitly based on the AWS Access Key ID signing the request.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"      
 :   return 
 :     user:getUser($aws-config, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to get information about. This parameter is optional. If it is not included, it defaults to the user making the request.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetUserResult element 
:)
declare %ann:sequential function user:getUser(
    $aws-config as element(aws-config),
    $userName as xs:string?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetUser" />,       
      utils:if-then($userName, <parameter name="UserName" value="{$userName}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Returns information about the Access Key IDs associated with the specified user. If there are none, the action returns an empty list.
 :
 : Although each user is limited to a small number of keys, you can still paginate the results using the MaxItems and Marker parameters.
 : If the UserName field is not specified, the UserName is determined implicitly based on the AWS Access Key ID used to sign the request. Because this action works for access keys under the AWS account, this API can be used to manage root credentials even if the AWS account has no associated users.
 :
 : If you do not specify a user name, IAM determines the user name implicitly based on the AWS Access Key ID signing the request.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"      
 :   return 
 :     user:listAccessKeys($aws-config, $userName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user.
 : @param $marker Use this parameter only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this parameter only when paginating results to indicate the maximum number of keys you want in the response. If there are additional keys beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListAccessKeysResult element 
:)
declare %ann:sequential function user:listAccessKeys(
    $aws-config as element(aws-config),
    $userName as xs:string?,
    $marker as xs:string?,
    $maxItems as xs:integer?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListAccessKeys" />,       
      utils:if-then($userName, <parameter name="UserName" value="{$userName}" />),
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Lists the account aliases associated with the account. 
 : For information about using an AWS account alias, see Using an Alias for Your AWS Account ID in Using AWS Identity and Access Management.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 : 
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 ::  
 :   user:listAccountAliases($aws-config, $userName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of account aliases you want in the response. If there are additional account aliases beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListAccountAliasesResponse element 
:)
declare %ann:sequential function user:listAccountAliases(
    $aws-config as element(aws-config),   
    $marker as xs:string?,
    $maxItems as xs:integer?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListAccountAliases" />,             
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Lists the groups that have the specified path prefix.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 : 
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $pathPrefix := "/division_abc/subdivision_xyz/"      
 :   return 
 :     user:listGroups($aws-config, $pathPrefix, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $pathPrefix The path prefix for filtering the results. For example: /division_abc/subdivision_xyz/, which would get all groups whose path starts with /division_abc/subdivision_xyz/. This parameter is optional. If it is not included, it defaults to a slash (/), listing all groups.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of groups you want in the response. If there are additional groups beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListGroupsResult element 
:)
declare %ann:sequential function user:listGroups(
    $aws-config as element(aws-config),   
    $pathPrefix as xs:string?,
    $marker as xs:string?,
    $maxItems as xs:integer?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListGroups" />,
      utils:if-then($pathPrefix, <parameter name="PathPrefix" value="{$pathPrefix}" />),             
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Lists the groups the specified user belongs to.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $userName := "Bob"      
 :   return 
 :     user:listGroupsForUser($aws-config, $userName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName The name of the user to list groups for.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of groups you want in the response. If there are additional groups beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListGroupsForUserResult element 
:)
declare %ann:sequential function user:listGroupsForUser(
    $aws-config as element(aws-config),   
    $userName as xs:string,
    $marker as xs:string?,
    $maxItems as xs:integer?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListGroupsForUser" />,
      <parameter name="UserName" value="{$userName}" />,             
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Lists the users that have the specified path prefix. If there are none, the action returns an empty list.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $pathPrefix := "/division_abc/subdivision_xyz/"      
 :   return 
 :     user:listUsers($aws-config, $pathPrefix, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $pathPrefix The path prefix for filtering the results. For example: /division_abc/subdivision_xyz/, which would get all user names whose path starts with /division_abc/subdivision_xyz/. This parameter is optional. If it is not included, it defaults to a slash (/), listing all user names.
 : @param $marker Use this parameter only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this parameter only when paginating results to indicate the maximum number of user names you want in the response. If there are additional user names beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListUsersResponse element 
:)
declare %ann:sequential function user:listUsers(
    $aws-config as element(aws-config),   
    $pathPrefix as xs:string?,
    $marker as xs:string?,
    $maxItems as xs:integer?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListUsers" />,
      utils:if-then($pathPrefix, <parameter name="PathPrefix" value="{$pathPrefix}" />),             
      utils:if-then($marker, <parameter name="Marker" value="{$marker}" />),
      utils:if-then($maxItems, <parameter name="MaxItems" value="{$maxItems}" />)      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Removes the specified user from the specified group.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $userName := "Bob" 
 :   let $groupName := "Clients"
 :   return 
 :     user:removeUserFromGroup($aws-config, $userName, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to update.
 : @param $groupName Name of the group to update.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the RemoveUserFromGroupResponse element 
:)
declare %ann:sequential function user:removeUserFromGroup(
    $aws-config as element(aws-config),   
    $userName as xs:string,
    $groupName as xs:string    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="RemoveUserFromGroup" />,
      <parameter name="UserName" value="{$userName}" />,
      <parameter name="GroupName" value="{$groupName}" />
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Changes the status of the specified access key from Active to Inactive, or vice versa. 
 : This action can be used to disable a user's key as part of a key rotation work flow.
 :
 : If the UserName field is not specified, the UserName is determined implicitly based on the AWS Access Key ID used to sign the request. 
 : Because this action works for access keys under the AWS account, this API can be used to manage root credentials even if the AWS account has no associated users.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:Bobcreate("aws-key","aws-secret");
 : 
 :   let $accessKeyId := "ABCDEFGHIJKLMNOPQRSTU"
 :   let $status := "Inactive"
     let $userName := "Bob"                        
 :   return 
 :     user:updateAccessKey($aws-config, $accessKeyId, $status, $userName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $accessKeyId The Access Key ID of the Secret Access Key you want to update.
 : @param $status The status you want to assign to the Secret Access Key. Active means the key can be used for API calls to AWS, while Inactive means the key cannot be used.
 : @param $userName Name of the user whose key you want to update. (Optional)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the UpdateAccessKeyResponse element 
:)
declare %ann:sequential function user:updateAccessKey(
    $aws-config as element(aws-config),   
    $accessKeyId as xs:string,
    $status as xs:string,
    $userName as xs:string?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="UpdateAccessKey" />,
      <parameter name="AccessKeyId" value="{$accessKeyId}" />,
      <parameter name="Status" value="{$status}" />,
      utils:if-then($userName,<parameter name="UserName" value="{$userName}" />)
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Updates the name and/or the path of the specified group.
 : 
 : You should understand the implications of changing a group's path or name. For more information, see Renaming Users and Groups in Using AWS Identity and Access Management.
 : 
 : To change a group name the requester must have appropriate permissions on both the source object and the target object. For example, to change Managers to MGRs, the entity making the request must have permission on Managers and MGRs, or must have permission on all (*). For more information about permissions, see Permissions and Policies.  
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $groupName := "Clients"
 :   let $newGroupName := "SausalitoUsers"
     let $newPath := "/division_abc/subdivision_xyz/"                        
 :   return 
 :     user:updateGroup($aws-config, $groupName, $newGroupName, $newPath)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group to update. If you're changing the name of the group, this is the original name.
 : @param $newGroupName New name for the group. Only include this if changing the group's name.
 : @param $newPath New path for the group. Only include this if changing the group's path.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the UpdateGroupResponse element 
:)
declare %ann:sequential function user:updateGroup(
    $aws-config as element(aws-config),   
    $groupName as xs:string,
    $newGroupName as xs:string?,
    $newPath as xs:string?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="UpdateGroup" />,
      <parameter name="GroupName" value="{$groupName}" />,
      utils:if-then($newGroupName,<parameter name="NewGroupName" value="{$newGroupName}" />),
      utils:if-then($newPath,<parameter name="NewPath" value="{$newPath}" />)
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Updates the login profile for the specified user. Use this API to change the user's password.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $userName := "Bob"
 :   let $password := "MySuperPassword"                            
 :   return 
 :     user:updateLoginProfile($aws-config, $userName, $password)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the group to update. If you're changing the name of the group, this is the original name.
 : @param $password New name for the group. Only include this if changing the group's name. 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the UpdateLoginProfileResponse element 
:)
declare %ann:sequential function user:updateLoginProfile(
    $aws-config as element(aws-config),   
    $userName as xs:string,
    $password as xs:string?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="UpdateLoginProfile" />,
      <parameter name="UserName" value="{$userName}" />,
      utils:if-then($password,<parameter name="Password" value="{$password}" />)
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Updates the name and/or the path of the specified user.
 :
 : You should understand the implications of changing a user's path or name. For more information, see Renaming Users and Groups in Using AWS Identity and Access Management.
 :
 : To change a user name the requester must have appropriate permissions on both the source object and the target object. For example, to change Bob to Robert, the entity making the request must have permission on Bob and Robert, or must have permission on all (*). For more information about permissions, see Permissions and Policies.
 :
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace user = "http://www.xquery.me/modules/xaws/iam/user";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 : 
 :   let $userName := "Bob"
 :   let $newUserName := "Bobby"
     let $newPath := "/division_abc/subdivision_xyz/"                        
 :   return 
 :     user:updateUser($aws-config, $userName, $newUserName, $newPath)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to update. If you're changing the name of the user, this is the original user name.
 : @param $newUserName New name for the user. Include this parameter only if you're changing the user's name.
 : @param $newPath New path for the user. Include this parameter only if you're changing the user's path.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the UpdateGroupResponse element 
:)
declare %ann:sequential function user:updateUser(
    $aws-config as element(aws-config),   
    $userName as xs:string,
    $newUserName as xs:string?,
    $newPath as xs:string?    
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="UpdateUser" />,
      <parameter name="UserName" value="{$userName}" />,
      utils:if-then($newUserName,<parameter name="NewUserName" value="{$newUserName}" />),
      utils:if-then($newPath,<parameter name="NewPath" value="{$newPath}" />)
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};



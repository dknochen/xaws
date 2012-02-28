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
module namespace policy = 'http://www.xquery.me/modules/xaws/iam/policy';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace iam_request = 'http://www.xquery.me/modules/xaws/iam/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/iam/error';

(: import module namespace json = "http://www.zorba-xquery.com/modules/converters/json"; :)

declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : Deletes the specified policy that is associated with the specified group.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"
 :   let $policyName := "DemoPolicy"      
 :   return 
 :     policy:deleteGroupPolicy($aws-config, $groupName, $policyName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group the policy is associated with.
 : @param $policyName Name of the policy document to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteGroupPolicyResponse element 
:)
declare %ann:sequential function policy:deleteGroupPolicy(
    $aws-config as element(aws-config),
    $groupName as xs:string,
    $policyName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteGroupPolicy" />,       
      <parameter name="GroupName" value="{$groupName}" />,
      <parameter name="PolicyName" value="{$policyName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Deletes the specified policy associated with the specified user.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"
 :   let $policyName := "DemoPolicy"      
 :   return 
 :     policy:deleteGroupPolicy($aws-config, $groupName, $policyName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user the policy is associated with.
 : @param $policyName Name of the policy document to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the DeleteUserPolicyResponse element 
:)
declare %ann:sequential function policy:deleteUserPolicy(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $policyName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="DeleteUserPolicy" />,       
      <parameter name="UserName" value="{$userName}" />,
      <parameter name="PolicyName" value="{$policyName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Retrieves the specified policy document for the specified group.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"
 :   let $policyName := "DemoPolicy"      
 :   return 
 :     policy:getGroupPolicy($aws-config, $groupName, $policyName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName Name of the group the policy is associated with.
 : @param $policyName Name of the policy to get.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetGroupPolicyResult element 
:)
declare %ann:sequential function policy:getGroupPolicy(
    $aws-config as element(aws-config),
    $groupName as xs:string,
    $policyName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetGroupPolicy" />,       
      <parameter name="GroupName" value="{$groupName}" />,
      <parameter name="PolicyName" value="{$policyName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Retrieves the specified policy document for the specified user. 
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"
 :   let $policyName := "DemoPolicy"      
 :   return 
 :     policy:getUserPolicy($aws-config, $groupName)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user the policy is associated with.
 : @param $policyName Name of the policy to get.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the GetGroupPolicyResult element 
:)
declare %ann:sequential function policy:getUserPolicy(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $policyName as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="GetUserPolicy" />,       
      <parameter name="UserName" value="{$userName}" />,
      <parameter name="PolicyName" value="{$policyName}" />               
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Lists the names of the policies associated with the specified group. 
 : If there are none, the action returns an empty list.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Clients"    
 :   return 
 :     policy:listGroupPolicies($aws-config, $userName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $groupName The name of the group to list policies for.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of policy names you want in the response. If there are additional policy names beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListUserPoliciesResult element 
:)
declare %ann:sequential function policy:listGroupPolicies(
    $aws-config as element(aws-config),
    $groupName as xs:string,
    $marker as xs:string?,
    $maxItems as xs:integer?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListGroupPolicies" />,       
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
 : Lists the names of the policies associated with the specified user. 
 : If there are none, the action returns an empty list.
 :
 : You can paginate the results using the MaxItems and Marker parameters.
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"    
 :   return 
 :     policy:listUserPolicies($aws-config, $userName, (), ())
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName The name of the user to list policies for.
 : @param $marker Use this only when paginating results, and only in a subsequent request after you've received a response where the results are truncated. Set it to the value of the Marker element in the response you just received.
 : @param $maxItems Use this only when paginating results to indicate the maximum number of policy names you want in the response. If there are additional policy names beyond the maximum you specify, the IsTruncated response element is true.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListUserPoliciesResult element 
:)
declare %ann:sequential function policy:listUserPolicies(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $marker as xs:string?,
    $maxItems as xs:integer?
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListUserPolicies" />,       
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
 : Adds (or updates) a policy document associated with the specified user.  
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $userName := "Bob"     
 :   let $policyName := "DemoPolicy"
 :   let $policyDocument := '{"Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}'
 :   return 
 :     policy:putuserPolicy($aws-config, $userName, $policyName, $policyDocument)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to associate the policy with.
 : @param $policyName Name of the policy document.
 : @param $policyDocument The policy document.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListUserPoliciesResult element 
:)
declare %ann:sequential function policy:putUserPolicy(
    $aws-config as element(aws-config),
    $userName as xs:string,
    $policyName as xs:string,
    $policyDocument as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="PutUserPolicy" />,       
      <parameter name="UserName" value="{$userName}" />,
      <parameter name="PolicyName" value="{$policyName}" />,
      <parameter name="PolicyDocument" value="{$policyDocument}" />      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Adds (or updates) a policy document associated with the specified group.  
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $groupName := "Client"     
 :   let $policyName := "DemoPolicy"
 :   let $policyDocument := '{"Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}'
 :   return 
 :     policy:putuserPolicy($aws-config, $groupName, $policyName, $policyDocument)
 : </code>
 :
 : 
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to AWS. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/helpers/config">config</a> module.
 : @param $userName Name of the user to associate the policy with.
 : @param $policyName Name of the policy document.
 : @param $policyDocument The policy document.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the ListUserPoliciesResult element 
:)
declare %ann:sequential function policy:putGroupPolicy(
    $aws-config as element(aws-config),
    $groupName as xs:string,
    $policyName as xs:string,
    $policyDocument as xs:string
) as item()* {

  let $href as xs:string := iam_request:href($aws-config, "iam.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="PutGroupPolicy" />,       
      <parameter name="GroupName" value="{$groupName}" />,
      <parameter name="PolicyName" value="{$policyName}" />,
      <parameter name="PolicyDocument" value="{$policyDocument}" />      
  )
  let $request := request:create("GET",$href,$parameters)
  let $response := iam_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : Converts an XML policy document into the JSON string representation used by Amazon
 :  
 : Example:
 : <code type="xquery">
 :   import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";
 :   import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
 :
 :   declare variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   let $policy :=      
 :      <Policy>
 :        <Statement>
 :          <Effect>Allow</Effect>
 :          <Action>iam:CreateAccessKey</Action> 
 :          <Action>iam:ListAccessKey</Action>
 :          <Action>iam:UpdateAccessKey</Action>
 :          <Action>iam:DeleteAccessKey</Action>
 :          <Resource>arn:aws:iam::123456789012:user/*</Resource>
 :          <Condition>
 :            <DateGreaterThan>
 :               <Key name="aws:CurrentTime">2010-07-01T00:00Z</Key>
 :            </DateGreaterThan>
 :          </Condition>
 :        </Statement>
 :        <Statement>
 :          <Effect>Allow</Effect>
 :          <Action>sdb:CreateDomain</Action>
 :          <Action>sdb:DeleteDomain</Action>
 :          <Resource>arn:aws:sdb:*:123456789012:domain/*</Resource>
 :        </Statement>
 :     </Policy>
 :   return 
 :     policy:create($policy)
 : </code>
 :
 : Put all statements inside a "Policy" root element. (See example)
 : The names for the XML elements are the same as for the JSON objects. 
 : If an array is used in the JSON representation use the corresponding XML element multiple times instead. 
 : For prefixed elements in conditions use a "Key" element and set the name using the @name attribute. 
 : 
 : @param $policyDoc The XML policy document to be converted. 
 : @return returns the policy document converted to an Amazon compatible JSON string   
:)
declare function policy:create($policyDoc as element(Policy)) as xs:string {
  policy:json-serialize(
    <json type="object">
      { policy:create-part($policyDoc/element()) }
    </json>
  )
};

(:~
 : Internally used only
 :)
declare %fn:private function policy:create-part($nodes) {
  for $node in $nodes
  let $local-name := fn:local-name($node)
  let $name := if ($local-name eq "Key") then xs:string($node/@name) else $local-name
  group by $name
  return    
    if ($node/element())
    then if (fn:count($node)>1)
         then <pair name="{$name[1]}" type="array">
              {
                for $item in $node return <item type="object">{ policy:create-part($item/node()) }</item>
              }
              </pair>
         else <pair name="{$name[1]}" type="object">{ policy:create-part($node/element()) }</pair>
    else if (fn:count($node)>1)
    then <pair name="{$name[1]}" type="array">
          { 
            for $item in $node return <item type="string">{ xs:string($item) }</item>
          }
         </pair>
    else <pair name="{$name}" type="string">{ xs:string($node) }</pair> 
};

(:~
 : Internally used only (Replacement for JSON serializer)
 :)
declare %fn:private function policy:json-serialize($json)  {  
    if ($json/@type="object")
    then fn:concat("{",policy:json-serializeMulti($json/element()),"}")
    else if ($json/@type="array")
    then fn:concat("[",policy:json-serializeMulti($json/element()),"]")
    else if ($json/@type="string")
    then fn:concat('"',fn:replace($json/text(),'"','\\"'),'"')
    else fn:error()
}; 

(:~
 : Internally used only (Replacement for JSON serializer)
 :)
declare %fn:private function policy:json-serializeMulti($json)  {
  fn:string-join(
    for $j in $json
    return
      if ($j/self::item)
      then policy:json-serialize($j)
      else if ($j/self::pair) 
      then fn:concat('"',fn:data($j/@name),'" : ',policy:json-serialize($j))
      else fn:error()
  ,",")
};

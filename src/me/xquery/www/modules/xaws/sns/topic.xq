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
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace sns_request = 'http://www.xquery.me/modules/xaws/sns/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/sns/error';

declare namespace sns = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : returns the unique topic-ARN
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-name The topic name
 : @return returns the unique topic-ARN found by the topic name
:)
declare %ann:sequential function topic:get-topicARN-by-topicName(
    $aws-config as element(aws-config),
    $topic-name as xs:string
) as item()* {

    let $topic-list := topic:list($aws-config)
    let $topic-arn := $topic-list//sns:Topics/sns:member/sns:TopicArn[ends-with(text(), concat(":", $topic-name))] 
    return 
      $topic-arn
};

(:~
 : list all topics of a user.
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListTopicResponse element 
:)
declare %ann:sequential function topic:list(
    $aws-config as element(aws-config)
) as item()* {

    topic:list($aws-config,())
    
};

(:~
 : list all topics of a user.
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListTopicResponse element 
:)
declare %ann:sequential function topic:list(
  $aws-config as element(aws-config),
  $next-token as xs:string?
) as item()* {

  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListTopics" />,
      utils:if-then ($next-token,
        <parameter name="NextToken" value="{$next-token}" />)  
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : create a topic for a user.
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $name The name of the topic you want to create. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, and hyphens, and must be between 1 and 256 characters long
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:CreateTopicResponse element 
:)
declare %ann:sequential function topic:create(
    $aws-config as element(aws-config),
    $name as xs:string
) as item()* {

  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="Name" value="{$name}" />,
      <parameter name="Action" value="CreateTopic" /> 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response
};

(:~
 : delete a topic of a user and all its subscriptions
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID (can be generated from the topic-name)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:DeleteTopicResponse element
:)
declare %ann:sequential function topic:delete(
    $aws-config as element(aws-config),
    $topic-arn as xs:string
) as item()* {
  
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" />,
      <parameter name="Action" value="DeleteTopic" /> 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response
};

(:~
 : list all of the requester´s subsriptions
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListSubscriptionsResponse element
:)
declare %ann:sequential function topic:list-subscriptions(
  $aws-config as element(aws-config)
) as item()* {

    topic:list-subscriptions($aws-config, ());
};

(:~
 : list all of the requester´s subsriptions
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListSubscriptionsResponse element
:)
declare %ann:sequential function topic:list-subscriptions(
  $aws-config as element(aws-config),
  $next-token as xs:string?
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="Action" value="ListSubscriptions" />,
      utils:if-then ($next-token,
        <parameter name="NextToken" value="{$next-token}" />)  
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : list all subscriptions to a specific topic
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListSubscriptionsByTopicResponse element
:)
declare %ann:sequential function topic:list-subscriptions-by-topic(
  $aws-config as element(aws-config),
  $topic-arn as xs:string
) as item()* {
    
    topic:list-subscriptions-by-topic($aws-config,$topic-arn, ());
};

(:~
 : list all subscriptions to a specific topic
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID 
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ListSubscriptionsByTopicResponse element
:)
declare %ann:sequential function topic:list-subscriptions-by-topic(
  $aws-config as element(aws-config),
  $topic-arn as xs:string,
  $next-token as xs:string?
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" /> ,
      <parameter name="Action" value="ListSubscriptionsByTopic" /> ,
      utils:if-then ($next-token,
        <parameter name="NextToken" value="{$next-token}" />)  
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : returns all of the properties of a topic
 :
 : NOTE: The response element will contain a map of topic´s attributes
 :       Attributes in this map include the following:
 :          - TopicArn -- the topic's ARN
 :          - Owner -- the AWS account ID of the topic's owner
 :          - Policy -- the JSON serialization of the topic's access control policy
 :          - DisplayName -- the human-readable name used in the "From" field for notifications to email and email-json endpoints
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:GetTopicAttributesResponse element
:)
declare %ann:sequential function topic:get-topic-attributes(
  $aws-config as element(aws-config),
  $topic-arn as xs:string
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" /> ,
      <parameter name="Action" value="GetTopicAttributes" />
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : change the display name of a topic
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID 
 : @param $display-name The new value to be set for the display name
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:SetTopicAttributesResponse element
:)
declare %ann:sequential function topic:set-display-name(
  $aws-config as element(aws-config),
  $topic-arn as xs:string,
  $display-name as xs:string
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" /> ,
      <parameter name="Action" value="SetTopicAttributes" /> ,
      <parameter name="AttributeName" value="DisplayName" /> ,
      <parameter name="AttributeValue" value="{$display-name}" />
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : prepares to subscribe an endpoint by sending the endpoint a confirmation message
 :
 : <code type="xquery">
 :   import module namespace config = 'http://www.xquery.me/modules/xaws/helpers/config';
 :   import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';
 :
 :   variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   topic:subscribe($aws-config,
 :     <subscription xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
 :       <TopicArn>arn:aws:sns:us-east-1:345345345:topic1</TopicArn>
 :       <Protocol>email</Protocol>
 :       <Endpoint>john@example.com</Endpoint>
 :     </subscription>);
 :  </code> 
 :
 : NOTE: Valid values for the parameters $protocol and $endpoint are:
 :          - $protocol: The protocol you want to use. Supported protocols are:
 :              - http -- delivery of JSON-encoded message via HTTP POST
 :              - https -- delivery of JSON-encoded message via HTTPS POST
 :              - email -- delivery of message via SMTP
 :              - email-json -- delivery of JSON-encoded message via SMTP
 :              - sqs -- delivery of JSON-encoded message to an Amazon SQS queue
 :          - $endpoint: The Endpoint you want to receive notifications. Endpoints vary by protocol:
 :              - For the http protocol, the endpoint is an URL beginning with "http://"
 :              - For the https protocol, the endpoint is a URL beginning with "https://"
 :              - For the email protocol, the endpoint is an e-mail address
 :              - For the email-json protocol, the endpoint is an e-mail address
 :              - For the sqs protocol, the endpoint is the ARN of an Amazon SQS queue
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $subscription Element containing the topic arn, protocol, and endpoint (e.g. url, email adress) for the subscription
 :                      (see example and more details above)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:SubscribeResponse element
:)
declare %ann:sequential function topic:subscribe(
  $aws-config as element(aws-config),
  $subscription as element(topic:subscription)
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$subscription/sns:TopicArn/text()}" /> ,
      <parameter name="Action" value="Subscribe" /> ,
      <parameter name="Protocol" value="{$subscription/sns:Protocol/text()}" /> ,
      <parameter name="Endpoint" value="{$subscription/sns:Endpoint/text()}" />
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : deletes a subscription
 :
 : NOTE: If the subscription requires authentication for deletion, 
 :       only the owner of the subscription or the its topic's owner 
 :       can unsubscribe, and an AWS signature is required. If the 
 :       Unsubscribe call does not require authentication and the 
 :       requester is not the subscription owner, a final 
 :       cancellation message is delivered to the endpoint, so that 
 :       the endpoint owner can easily resubscribe to the topic if 
 :       the Unsubscribe request was unintended.
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $subscription-arn The ARN of the subscription to be deleted 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:UnsubscribeResponse element
:)
declare %ann:sequential function topic:unsubscribe(
  $aws-config as element(aws-config),
  $subscription-arn as xs:string
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="SubscriptionArn" value="{$subscription-arn}" /> ,
      <parameter name="Action" value="Unsubscribe" /> 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action
 : It´s not mandatory to sign this request
 :
 :
 : @param $topic-arn The Topic ID
 : @param $token The token sent to an endpoint during the Subscribe action 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ConfirmSubscriptionResponse element
:)
declare %ann:sequential function topic:confirm-subscription(
    $topic-arn as xs:string,
    $token as xs:string
) as item()* {
    
    topic:confirm-subscription((),$topic-arn,$token, ())
};

(:~
 : verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action
 : It´s not mandatory to sign this request
 :
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID
 : @param $token The token sent to an endpoint during the Subscribe action 
 : @param $authenticate-on-unsubscribe valid values are True or False. Indicates that the user want to disable unauthenticated unsubsciption of the subscription (Therefore you have to sign the request)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:ConfirmSubscriptionResponse element
:)
declare %ann:sequential function topic:confirm-subscription(
  $aws-config as element(aws-config)?,
  $topic-arn as xs:string,
  $token as xs:string,
  $authenticate-on-unsubscribe as xs:string?
) as item()* {
  
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" /> ,
      <parameter name="Action" value="ConfirmSubscription" /> ,
      <parameter name="Token" value="{$token}" /> ,
      utils:if-then ($authenticate-on-unsubscribe,
        <parameter name="AuthenticateOnUnsubscribe" value="{$authenticate-on-unsubscribe}" />) 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response
 
};

(:~
 : sends a message to all of a topic's subscribed endpoints
 :
 :
 : <code type="xquery">
 :   import module namespace config = 'http://www.xquery.me/modules/xaws/helpers/config';
 :   import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';
 :
 :   variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   topic:publish($aws-config,
 :     <notification xmlns="http://www.xquery.me/modules/xaws/sns/topic"> 
 :       <TopicArn>arn:aws:sns:us-east-1:345345345:topic1</TopicArn>
 :       <Subject>Hello World</Subject>
 :       <Message>
 :         Hello List,
 :         this is just a test notification.
 :       </Message>
 :     </notification>);
 :  </code> 
 :
 : Constraints: 
 : <ul>
 :   <li>Messages must be UTF-8 encoded strings at most 8 KB in size (8192 bytes, not 8192 characters).</li>
 :   <li>Subjects must be ASCII text that begins with a letter, number or punctuation mark; 
         must not include line breaks or control characters; and must be less than 100 characters long.</li>
 : </ul>
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $notification Element containing the topic arn, a subject (optional), and a message text for a notification (see example above)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:PublishResponse element
:)
declare %ann:sequential function topic:publish(
  $aws-config as element(aws-config),
  $notification as element(topic:notification)
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$notification/topic:TopicArn/text()}" /> ,
      <parameter name="Action" value="Publish" /> ,
      <parameter name="Message" value="{string-join($notification/topic:Message/text(),"&#13;")}" /> ,
      utils:if-then ($notification/topic:Subject/text(),
        <parameter name="Subject" value="{$notification/topic:Subject/text()}" />) 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response
 
};

(:~
 : add permissions for one or multiple AWS user accounts to a topic
 :
 : <code type="xquery">
 :   import module namespace config = 'http://www.xquery.me/modules/xaws/helpers/config';
 :   import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';
 :
 :   variable $aws-config := config:create("aws-key","aws-secret");
 :
 :   topic:add-permissions($aws-config,
 :     <permissions xmlns="http://www.xquery.me/modules/xaws/sns/topic"
 :                  label="MyUniquePermission"> 
 :       <TopicArn>arn:aws:sns:us-east-1:345345345:topic1</TopicArn>
 :       <AWSAccountId>33345345345</AWSAccountId>
 :       <AWSAccountId>12453456755</AWSAccountId>
 :       <ActionName>Publish</ActionName>
 :       <ActionName>Subscribe</ActionName>
 :       <ActionName>Receive</ActionName>
 :     </permissions>);
 :  </code> 
 :
 :
 : NOTE: Valid values for the parameter $action-name are:
 :          - "Publish",
 :          - "RemovePermission",
 :          - "SetTopicAttributes",
 :          - "DeleteTopic",
 :          - "ListSubscriptionsByTopic",
 :          - "GetTopicAttributes",
 :          - "Receive",
 :          - "AddPermission",
 :          - "Subscribe"
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $permissions Element containing a unique label identifying these permissions, the topic arn, AWS account 
 :                     ids, and actions for granting permissions (see example above)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:AddPermissionResponse element 
:)
declare %ann:sequential function topic:add-permissions(
  $aws-config as element(aws-config),
  $permissions as element(topic:permissions)
) as item()* {
      
  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$permissions/topic:TopicArn/text()}" />,
      <parameter name="Action" value="AddPermission" /> ,
      <parameter name="Label" value="{$label}" /> ,
      for $action at $idx in $permissions/topic:ActionName
      return
        <parameter name="ActionName.member.{$idx}" value="{$action/text()}" /> ,
      for $account at $idx in $permissions/topic:AWSAccountId
      return
        <parameter name="AWSAccountId.member.{$idx}" value="{$account/text()}" /> 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

(:~
 : removes permissions form a topic identified by a label
 :
 : @param $aws-config The aws-config element containing authentication information for connections
 :                    to S3. The aws-config element can conveniently be created using the <code>create</code>
 :                    function within the <a href="http://www.xquery.me/modules/xaws/s3/config">config</a> module.
 : @param $topic-arn The Topic ID
 : @param $label The unique identifier for the policy statement to be deleted
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the sns:RemovePermissionResponse  element 
:)
declare %ann:sequential function topic:remove-permission(
  $aws-config as element(aws-config),
  $topic-arn as xs:string,
  $label as xs:string
) as item()* {

  let $href as xs:string := request:href($aws-config, "sns.us-east-1.amazonaws.com/")
  let $parameters := (
      <parameter name="TopicArn" value="{$topic-arn}" /> ,
      <parameter name="Action" value="RemovePermission" /> ,
      <parameter name="Label" value="{$label}" /> 
    )
  let $request := request:create("GET",$href,$parameters)
  let $response := sns_request:send($aws-config,$request,$parameters)
  return 
    $response

};

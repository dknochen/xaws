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
 :)
module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace sns_request = 'http://www.xquery.me/modules/xaws/sns/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/sns/error';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";


declare variable $topic:host as xs:string := "sns.us-east-1.amazonaws.com";
declare variable $topic:path as xs:string := "/";
declare variable $topic:href as xs:string := concat("http://",$topic:host,$topic:path);
declare variable $topic:arn as xs:string := "";

(:~
 : returns the unique topic-ARN
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-name The topic name
 : @return returns the unique topic-ARN found by the topic name
:)
declare %ann:sequential function topic:get-topicARN-by-topicName(
    $topic-name as xs:string,
    $aws-access-key as xs:string, 
    $aws-secret as xs:string
) as item()* {

    variable $topic-list := topic:list($aws-access-key,$aws-secret);
    variable $topic-arn := $topic-list//aws:Topics/aws:member/aws:TopicArn[ends-with(text(), concat(":", $topic-name))]; 

    $topic-arn
};

(:~
 : list all topics of a user.
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListTopicResponse element 
:)
declare %ann:sequential function topic:list(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string
) as item()* {

    topic:list($aws-access-key,$aws-secret,())
    
};

(:~
 : list all topics of a user.
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListTopicResponse element 
:)
declare %ann:sequential function topic:list(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $next-token as xs:string?
) as item()* {

    let $parameters := (
            <parameter name="Action" value="ListTopics" /> ,
            if ($next-token)
            then
                <parameter name="NextToken" value="{$next-token}" />  
            else
                ()
        )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send(fn:trace($request, "blub"))
        }
};

(:~
 : create a topic for a user.
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $name The name of the topic you want to create. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, and hyphens, and must be between 1 and 256 characters long
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:CreateTopicResponse element 
:)
declare %ann:sequential function topic:create(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $name as xs:string
) as item()* {

    let $parameters := (
        <parameter name="Name" value="{$name}" />,
        <parameter name="Action" value="CreateTopic" /> 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : delete a topic of a user and all its subscriptions
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID (can be generated from the topic-name)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:DeleteTopicResponse element
:)
declare %ann:sequential function topic:delete(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string
) as item()* {
  
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" />,
        <parameter name="Action" value="DeleteTopic" /> 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : list all of the requester´s subsriptions
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListSubscriptionsResponse element
:)
declare %ann:sequential function topic:list-subscriptions(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string
) as item()* {

    topic:list-subscriptions($aws-access-key,$aws-secret, ());
};

(:~
 : list all of the requester´s subsriptions
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListSubscriptionsResponse element
:)
declare %ann:sequential function topic:list-subscriptions(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $next-token as xs:string?
) as item()* {
      
    let $parameters := (
        <parameter name="Action" value="ListSubscriptions" /> ,
        if ($next-token)
        then
            <parameter name="NextToken" value="{$next-token}" /> 
        else
            ()
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
        
};

(:~
 : list all subscriptions to a specific topic
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListSubscriptionsByTopicResponse element
:)
declare %ann:sequential function topic:list-subscriptions-by-topic(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string
) as item()* {
    
    topic:list-subscriptions-by-topic($aws-access-key,$aws-secret,$topic-arn, ());
};

(:~
 : list all subscriptions to a specific topic
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID 
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListSubscriptionsByTopicResponse element
:)
declare %ann:sequential function topic:list-subscriptions-by-topic(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $next-token as xs:string?
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="ListSubscriptionsByTopic" /> ,
        if ($next-token)
        then
            <parameter name="NextToken" value="{$next-token}" /> 
        else
            ()
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
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
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:GetTopicAttributesResponse element
:)
declare %ann:sequential function topic:get-topic-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="GetTopicAttributes" />
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : set an attribute of the topic to a new value
 :
 : NOTE: At this moment only the Attribute "DisplayName" is changeable by this function by AWS
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID 
 : @param $att-name The name of the attribute the user want to set. Only a subset of the topic's attributes are mutable
 : @param $att-value The new value for the attribute
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:SetTopicAttributesResponse element
:)
declare %ann:sequential function topic:set-topic-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $attr-name as xs:string,
    $attr-value as xs:string
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="SetTopicAttributes" /> ,
        <parameter name="AttributeName" value="{$attr-name}" /> ,
        <parameter name="AttributeValue" value="{$attr-value}" />
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : prepares to subscribe an endpoint by sending the endpoint a confirmation message
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
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $protocol The protocol the user want to use (valid: http, https, email, email-json, sqs)
 : @param $endpoint The endpoint the user want to receive notifications. Endpoints vary by protocol (http + https = [URL], email + email-json = [email-adress], sqs = [ARN of an Amazon SQS queue]
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:SubscribeResponse element
:)
declare %ann:sequential function topic:subscribe(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $protocol as xs:string,
    $endpoint as xs:string
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="Subscribe" /> ,
        <parameter name="Protocol" value="{$protocol}" /> ,
        <parameter name="Endpoint" value="{$endpoint}" />
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
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
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $subscription-arn The ARN of the subscription to be deleted 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:UnsubscribeResponse element
:)
declare %ann:sequential function topic:unsubscribe(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $subscription-arn as xs:string
) as item()* {
      
    let $parameters := (
        <parameter name="SubscriptionArn" value="{$subscription-arn}" /> ,
        <parameter name="Action" value="Unsubscribe" /> 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action
 : It´s not mandatory to sign this request
 :
 :
 : @param $topic-arn The Topic ID
 : @param $token The token sent to an endpoint during the Subscribe action 
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ConfirmSubscriptionResponse element
:)
declare %ann:sequential function topic:confirm-subscription(
    $topic-arn as xs:string,
    $token as xs:string
) as item()* {
    
    topic:confirm-subscription((),(),$topic-arn,$token, ())
};

(:~
 : verifies an endpoint owner's intent to receive messages by validating the token sent to the endpoint by an earlier Subscribe action
 : It´s not mandatory to sign this request
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $token The token sent to an endpoint during the Subscribe action 
 : @param $authenticate-on-unsubscribe valid values are True or False. Indicates that the user want to disable unauthenticated unsubsciption of the subscription (Therefore you have to sign the request)
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ConfirmSubscriptionResponse element
:)
declare %ann:sequential function topic:confirm-subscription(
    $aws-access-key as xs:string?, 
    $aws-secret as xs:string?,
    $topic-arn as xs:string,
    $token as xs:string,
    $authenticate-on-unsubscribe as xs:string?
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="ConfirmSubscription" /> ,
        <parameter name="Token" value="{$token}" /> ,
        if ($authenticate-on-unsubscribe)
        then
            <parameter name="AuthenticateOnUnsubscribe" value="{$authenticate-on-unsubscribe}" /> 
        else
            () 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
    if ($authenticate-on-unsubscribe)
    then
        {
        (: sign the request :)
        request:sign-v2(
            $request,
            $topic:host,
            $topic:path,
            $parameters,
            $aws-access-key,
            $aws-secret);
            
        sns_request:send($request)
    } 
    else
        sns_request:send($request) 
};

(:~
 : sends a message to all of a topic's subscribed endpoints
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $message The message the user want to send to the topic. Constraints: Messages must be UTF-8 encoded strings at most 8 KB in size (8192 bytes, not 8192 characters).
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:PublishResponse element
:)
declare %ann:sequential function topic:publish(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $message as xs:string
) as item()* {

    topic:publish($aws-access-key,$aws-secret,$topic-arn,$message, ())
};

(:~
 : sends a message to all of a topic's subscribed endpoints
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $message The message the user want to send to the topic. Constraints: Messages must be UTF-8 encoded strings at most 8 KB in size (8192 bytes, not 8192 characters). 
 : @param $subject Optional parameter to be used as subject line. Constraints: Subjects must be ASCII text that begins with a letter, number or punctuation mark; must not include line breaks or control characters; and must be less than 100 characters long.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:PublishResponse element
:)
declare %ann:sequential function topic:publish(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $message as xs:string,
    $subject as xs:string?
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="Publish" /> ,
        <parameter name="Message" value="{$message}" /> ,
        if ($subject)
        then
            <parameter name="Subject" value="{$subject}" /> 
        else
            () 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : adds a statement to a topic's access control policy
 :
 : TODO: Mehrere Acc´s und Actions implementieren?!
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
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $label The UNIQUE identifier for the new policy statement
 : @param $action-name The action the user want to allow for the specified principal(s)
 : @param $aws-account-id The AWS account ID of the principal who will be given access to the specified action
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:AddPermissionResponse element 
:)
declare %ann:sequential function topic:add-permission(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $label as xs:string,
    $action-name as xs:string,
    $aws-account-id as xs:string
) as item()* {
      
    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="AddPermission" /> ,
        <parameter name="Label" value="{$label}" /> ,
        <parameter name="ActionName.member.1" value="{$action-name}" /> ,
        <parameter name="AWSAccountId.member.1" value="{$aws-account-id}" /> 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

(:~
 : removes a statement from a topic's access control policy
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $topic-arn The Topic ID
 : @param $label The unique identifier for the policy statement to be deleted
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:RemovePermissionResponse  element 
:)
declare %ann:sequential function topic:remove-permission(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $topic-arn as xs:string,
    $label as xs:string
) as item()* {

    let $parameters := (
        <parameter name="TopicArn" value="{$topic-arn}" /> ,
        <parameter name="Action" value="RemovePermission" /> ,
        <parameter name="Label" value="{$label}" /> 
    )
    let $request := request:create("GET",$topic:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $topic:host,
                $topic:path,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sns_request:send($request)
        }
};

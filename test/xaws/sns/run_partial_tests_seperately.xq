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
 :      This file will allow you to execute the particular tests you 
 :      want to run.
 :
 :      IMPORTANT:
 :      Due to the fact that some variables have to be set before executing 
 :      each test, please refer to each particular test you want to run first,
 :      then customize the CONFIGURATION AREA below.
 :
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
import module namespace list_topics = 'http://test/xaws/sns/particular_tests/list_topics' at "particular_tests/list_topics.xq"; 
import module namespace create_topic = 'http://test/xaws/sns/particular_tests/create_topic' at "particular_tests/create_topic.xq";
import module namespace list_subscriptions = 'http://test/xaws/sns/particular_tests/list_subscriptions' at "particular_tests/list_subscriptions.xq";
import module namespace subscribe = 'http://test/xaws/sns/particular_tests/subscribe' at "particular_tests/subscribe.xq";
import module namespace list_subscriptions_by_topic = 'http://test/xaws/sns/particular_tests/list_subscriptions_by_topic' at "particular_tests/list_subscriptions_by_topic.xq";
import module namespace confirm_subscription = 'http://test/xaws/sns/particular_tests/confirm_subscription' at "particular_tests/confirm_subscription.xq";
import module namespace publish = 'http://test/xaws/sns/particular_tests/publish' at "particular_tests/publish.xq";
import module namespace unsubscribe = 'http://test/xaws/sns/particular_tests/unsubscribe' at "particular_tests/unsubscribe.xq";
import module namespace add_permission = 'http://test/xaws/sns/particular_tests/add_permission' at "particular_tests/add_permission.xq";
import module namespace remove_permission = 'http://test/xaws/sns/particular_tests/remove_permission' at "particular_tests/remove_permission.xq";
import module namespace get_topic_attributes = 'http://test/xaws/sns/particular_tests/get_topic_attributes' at "particular_tests/get_topic_attributes.xq";
import module namespace set_topic_attributes = 'http://test/xaws/sns/particular_tests/set_topic_attributes' at "particular_tests/set_topic_attributes.xq";
import module namespace delete_topic = 'http://test/xaws/sns/particular_tests/delete_topic' at "particular_tests/delete_topic.xq";

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

(:
********** CONFIGURATION AREA **********

    set as interpreter arguments in run configuration, e.g.:
    -e "aws-key:=yourkey" -e "aws-secret:=yoursecret" 
:)
declare variable $aws-key as xs:string external;
declare variable $aws-secret as xs:string external;

(:
    Set/change the following variables:
    
    IMPORTANT: Please refer to each partial test you want to execute
               to understand, what variables you have to set for 
               running it.
:)
declare variable $topic-name as xs:string := "test-topic";
declare variable $protocol as xs:string := "email-json";
declare variable $endpoint as xs:string := "klaus@XQuery.me";
declare variable $topic-arn as xs:string := "arn:aws:sns:us-east-1:693532245671:test-topic";
declare variable $conf-token as xs:string := "51b2ff3edb4487553c7dd2f29566c2aecada226c4aa0168a4b89c89a93846f70242d22ac952a4fe0bc2c145c4abeefa5a00cd4d17a0cd439885ad06d2d07d6e3b88c107ed0a4b7957b14e5dbb92f173c7b5b112696a24c703ed209e5802928f38df3988f3b9f767867eadfaf4f23a0ee";
declare variable $subject as xs:string := "This is an message created by the SNS Testsuite Part Two";
declare variable $message as xs:string := "This message just contains test content...";
declare variable $label as xs:string := "TestPermission";
declare variable $aws-account-id as xs:string := "192545610037";
declare variable $action-name as xs:string := "Publish";
declare variable $attribute-name as xs:string := "DisplayName";
declare variable $attribute-value as xs:string := "NewDisplayName";

(:
********** END OF CONFIGURATION AREA **********
:)

declare variable $success as xs:boolean := false();

declare variable $testconfig :=
    <config>
        <aws-key>{$aws-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
        <topic-name>{$topic-name}</topic-name>
        <protocol>{$protocol}</protocol>
        <endpoint>{$endpoint}</endpoint>
        <topic-arn>{$topic-arn}</topic-arn>
        <conf-token>{$conf-token}</conf-token>
        <subject>{$subject}</subject>
        <message>{$message}</message>
        <label>{$label}</label>
        <aws-account-id>{$aws-account-id}</aws-account-id>
        <action-name>{$action-name}</action-name>
        <attr-name>{$attribute-name}</attr-name>
        <attr-value>{$attribute-value}</attr-value>
    </config>;

declare variable $testresult := <testresult />;

(: **************************************************************************************
   Choose the tests you want to run
:)

(: create a topic :)
(:create_topic:run($testconfig,$testresult);:)
        
(: list all topics :)
(:list_topics:run($testconfig,$testresult);:)
                
(: List the requester´s subscriptions :)
(:list_subscriptions:run($testconfig,$testresult);:)
                        
(: Subscribe the topic :)
(:subscribe:run($testconfig,$testresult);:)

(: list all existing subscriptions by the specified topic :)
(:list_subscriptions_by_topic:run($testconfig,$testresult);:)

(: Confirm the subscription :)
(:confirm_subscription:run($testconfig,$testresult);:)
        
(: publish a message to all of a topic's subscribed endpoints :)
(:publish:run($testconfig,$testresult);:)
                        
(: unsubscribe :)
(:unsubscribe:run($testconfig,$testresult);:)
                                
(: get all attributes :)
(:get_topic_attributes:run($testconfig,$testresult);:)
                                        
(: add permission :)
(:add_permission:run($testconfig,$testresult);:)
                                                
(: set attribute :)
(:set_topic_attributes:run($testconfig,$testresult);:)
        
(: remove permission :)
(:remove_permission:run($testconfig,$testresult);:)
                        
(: delete the test topic to re-establish the initial condition :)
delete_topic:run($testconfig,$testresult);

(: ************************************************************************************** :)

$testresult;

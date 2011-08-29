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
 :      This testsuite will execute all of the particular tests (to be found 
 :      in the folder /test/xaws/sns/particular_tests/ ) in a reasonable
 :      order to demonstrate, that all of the implemented functions of the 
 :      SNS-Connector are working properly. 
 :
 :      IMPORTANT:
 :      Due to the fact that a user input is essential, this testsuite is divided 
 :      into two coherent fragments.
 :      Some variables have to be set before running each testsuite, please refer
 :      to the CONFIGURATION AREA below.
 :
 :      NOTE: In the end, you will see the result on your console output. If an 
 :            error occurs, the suite will stop at this point (no further tests
 :            will be executed) and on the console you will find the result with
 :            an error description.
 :
 :      NOTE: If you´ve finished both testsuite fragments, your SNS repository
 :            will not contain any test-data. The initial condition will be 
 :            re-established.
 :
 :
 :***************************************************************************************
 :
 :      --- PART TWO ---
 :
 :      - First of all set the following variables in the CONFIGURATION AREA below:
 :          - $aws-key
 :          - $aws-secret
 :          - $topic-arn 
 :          - $conf-token 
 :          - $message
 :          - $subject
 :          - $label 
 :          - $aws-account-id 
 :          - $action-name 
 :          - $attribute-name 
 :          - $attribute-value
 :
 :
 :      - This fragment will execute the following particular tests:
 :        (for a detailed description of each particular test refer to the test itself)
 :
 :          - list_subscriptions_by_topic: returns a (limited) list of the topic´s 
 :                                         subscriptions.
 :          - confirm_subscription: completes an earlier Subscriber action by 
 :                                  validating the token sent to the endpoint via the 
 :                                  choosen protocol.
 :          - list_subscriptions_by_topic: again, you can see that your subscription 
 :                                         was successfully created.
 :          - publish: sends a message to all of a topic's subscribed endpoints.
 :          - unsubscribe: deletes the subscription
 :          - get_topic_attributes: show´s all of the properties of a topic
 :          - add_permission: adds a statement to a topic's access control policy
 :          - set_topic_attributes: allows a topic owner to set an attribute of the 
 :                                  topic to a new value
 :          - get_topic_attributes: again, to show the changes the previous two tests 
 :                                  have done
 :          - remove_permission: removes a statement from a topic's access control 
 :                               policy.
 :          - delete_topic: deletes the test topic to re-establish the initial condition 
 :
 :***************************************************************************************
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)

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
        @param $topic-arn the topic ID this test run on (e.g. extract this information from the result of test_suite_part_1
        @param $conf-token the configuration token, extract this from your choosen endpoint (e.g. your Email-Account
        @param $subject OBLIGATORY the subject your message will be published with
        @param $message the message you will publish to the endpoints of the choosen Topic
        @param $label the UNIQUE label for the permission that will be added
        @param $aws-account-id the AWS-AccountID the specified action will be allowed
        @param $action-name the action the specified AWS-Account will be able to execute
        @param $attribute-name the name of the attribute which should be changed (at this moment only "DisplayName" is changeable by the AWS)
        @param $attribute-value the new value of the attribute to be changed
:)

declare variable $topic-arn as xs:string := "arn:aws:sns:us-east-1:693532245671:test-topic";
declare variable $conf-token as xs:string := "2336412f37fb687f5d51e6e241d3b4d5c22814cb363f06b2fdfec5167a0e836460c337f09f5d75974a7ce892ffc3adfb82e2604634f9a1ac0ebc0b683ff28375c273872aadc3dd32739ac89936b8277690ad53ac03cd8b38cbebbb19f7fb7f3564b0e9d4d37b87cfd1e4e658ae8aeefb";
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

declare variable $subscription-arn as xs:string := "";
declare variable $success as xs:boolean := false();

declare variable $testconfig :=
    <config>
        <aws-key>{$aws-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
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

(: list all existing subscriptions by the specified topic. 
   For the endpoint you´ve made a subscription in part one, 
   at "SubscriptionARN" should be the status "PendingConfirmation" :)
list_subscriptions_by_topic:run($testconfig,$testresult);

if (data($testresult/particular_test/@success)[1] eq "true")
then
    block {
        (: Confirm the subscription :)
        confirm_subscription:run($testconfig,$testresult);
        
        (: save the subscription-ARN in the testconfig :)
        set $subscription-arn := ($testresult/particular_test/subscriptionARN/text())[1];
        insert node <subscription-arn>{$subscription-arn}</subscription-arn> as last into $testconfig;
                
        if (data($testresult/particular_test/@success)[2] eq "true")
        then
            block {
                (: list all existing subscriptions by the specified topic. 
                   For the endpoint you´ve made a subscription in part one, 
                   at "SubscriptionARN" should no longer be the status 
                   "PendingConfirmation" but an unique SubscriptionARN :)
                list_subscriptions_by_topic:run($testconfig,$testresult);
                
                if (data($testresult/particular_test/@success)[3] eq "true")
                then
                    block {
                        (: publish a message to all of a topic's subscribed endpoints :)
                        publish:run($testconfig,$testresult);
                        
                        if (data($testresult/particular_test/@success)[4] eq "true")
                        then
                            block {
                                (: unsubscribe :)
                                unsubscribe:run($testconfig,$testresult);
                                
                                if (data($testresult/particular_test/@success)[5] eq "true")
                                then
                                    block {
                                        (: get all attributes :)
                                        get_topic_attributes:run($testconfig,$testresult);
                                        
                                        if (data($testresult/particular_test/@success)[6] eq "true")
                                        then
                                            block {
                                                (: add permission :)
                                                add_permission:run($testconfig,$testresult);
                                                
                                                if (data($testresult/particular_test/@success)[7] eq "true")
                                                then
                                                    block {
                                                        (: set attribute :)
                                                        set_topic_attributes:run($testconfig,$testresult);
                                                        
                                                        if (data($testresult/particular_test/@success)[8] eq "true")
                                                        then
                                                            block {
                                                                (: get all attributes again to show the changes :)
                                                                get_topic_attributes:run($testconfig,$testresult);
                                                                
                                                                if (data($testresult/particular_test/@success)[9] eq "true")
                                                                then
                                                                    block {
                                                                        (: remove permission :)
                                                                        remove_permission:run($testconfig,$testresult);
                                                                        
                                                                        if (data($testresult/particular_test/@success)[10] eq "true")
                                                                        then
                                                                            block {
                                                                                (: delete the test topic to re-establish the initial condition :)
                                                                                delete_topic:run($testconfig,$testresult);
                                                                                
                                                                                if (data($testresult/particular_test/@success)[11] eq "true")
                                                                                then
                                                                                    block {
                                                                                        (: set the final state of this test run :)
                                                                                        set $success := true();
                                                                                    }
                                                                                else ();
                                                                            }
                                                                        else ();
                                                                    }
                                                                else ();
                                                            }
                                                        else ();
                                                    }
                                                else ();
                                            }
                                        else ();
                                    }
                                else ();
                            }
                        else ();
                    }
                else ();
            }
        else ();
    }
else ();


if ($success)
then
    insert node <overall_result>"Success"</overall_result> as last into $testresult
else
    insert node <overall_result>"Failed"</overall_result> as last into $testresult;

$testresult;

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
 :      --- PART ONE ---
 :
 :      - First of all set the following variables in the CONFIGURATION AREA below:
 :          - $aws-key
 :          - $aws-secret
 :          - $topic-name 
 :          - $protocol 
 :          - $endpoint
 :
 :
 :      - This fragment will execute the following particular tests:
 :        (for a detailed description of each particular test refer to the test itself)
 :
 :          - list_topics: This test returns a (limited) list of the requesters topics.
 :          - create_topic: This test creates a topic if it´s not already exists.
 :          - list_topics: again, you can see that your topic is created.
 :          - list_subscriptions: This test returns a (limited) list of the requesters 
 :                                subscriptions.
 :          - subscribe: This test prepares to create a subscription by sending the 
 :                       endpoint a confirmation message.
 :
 :      If this part ends successfully, you will find at the end of your result on the
 :      console the Topic-ARN to be transferred into test_suite_part_2.
 :
 :***************************************************************************************
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
import module namespace list_topics = 'http://test/xaws/sns/particular_tests/list_topics' at "particular_tests/list_topics.xq"; 
import module namespace create_topic = 'http://test/xaws/sns/particular_tests/create_topic' at "particular_tests/create_topic.xq";
import module namespace list_subscriptions = 'http://test/xaws/sns/particular_tests/list_subscriptions' at "particular_tests/list_subscriptions.xq";
import module namespace subscribe = 'http://test/xaws/sns/particular_tests/subscribe' at "particular_tests/subscribe.xq";

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
    Set/change the following three variables:
        @param $topic-name the name of the topic to be created
        @param $protocol the protocol your endpoint want to use 
                        (refer to the partial test to have an idea 
                        what are valid values)
        @param endpoint the address of the endpoint
:)
declare variable $topic-name as xs:string := "test-topic";
declare variable $protocol as xs:string := "email-json";
declare variable $endpoint as xs:string := "klaus@XQuery.me";

(:
********** END OF CONFIGURATION AREA **********
:)

declare variable $topic-arn as xs:string := "";
declare variable $success as xs:boolean := false();

declare variable $testconfig :=
    <config>
        <aws-key>{$aws-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
        <topic-name>{$topic-name}</topic-name>
        <protocol>{$protocol}</protocol>
        <endpoint>{$endpoint}</endpoint>
    </config>;

declare variable $testresult := <testresult />;

(: list all existing topics before the own topic will be created :)
list_topics:run($testconfig,$testresult);

if (data($testresult/particular_test/@success)[1] eq "true")
then
    block {
    
        (: create a topic :)
        create_topic:run($testconfig,$testresult);
        
        if (data($testresult/particular_test/@success)[2] eq "true")
        then
            block {
                (: save the topic-ARN in the testconfig :)
                set $topic-arn := ($testresult/particular_test/topicARN/text())[1];
                insert node <topic-arn>{$topic-arn}</topic-arn> as last into $testconfig;
                
                (: list all topics again --> the created topic is in this list :)
                list_topics:run($testconfig,$testresult);
                
                if (data($testresult/particular_test/@success)[3] eq "true")
                then
                    block {
                    
                        (: List the requester´s subscriptions :)
                        list_subscriptions:run($testconfig,$testresult);
                        
                        if (data($testresult/particular_test/@success)[4] eq "true")
                        then
                            block {
                                
                                (: Subscribe the topic :)
                                subscribe:run($testconfig,$testresult);
                                
                                if (data($testresult/particular_test/@success)[5] eq "true")
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


if ($success)
then
    insert node <overall_result>"Success"</overall_result> as last into $testresult
else
    insert node <overall_result>"Failed"</overall_result> as last into $testresult;

if ($success)
then
    insert nodes <copy_into_testsuite_part2>
                    <topic-arn>{$topic-arn}</topic-arn>
                </copy_into_testsuite_part2>
    as last into $testresult
else ();


$testresult;

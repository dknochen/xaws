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
 :      This test creates a topic
 :      Note: In AWS, the function "CreateTopic" is idempotent. That means, AWS will also give a 
 :            positive result, if a topic with a similar name already exists and was not created 
 :            by this test (because topic-names have to be unique!) 
 :            To assure that this test only have a positive result if the topic was really created,
 :            this test first will verify that the topic-name not exists in AWS already.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/create_topic';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    declare $success := false();
    declare $msg := ();
    declare $testname := "sns_create_topic";
    declare $topic-name := string($testconfig/topic-name/text());
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    
    declare $response;
    declare $topic-arn := "";
    declare $topic-list;
    
    try {
        (: Try to get the unique topic-ARN by the given topic-name :)
        set $topic-arn := topic:get-topicARN-by-topicName($topic-name,$aws-key,$aws-secret);
        
        (: if there´s no topic-ARN, the given topic-name does not exist already :)
        if(not($topic-arn))
        then
            block {
                (: create the topic :)
                set $response := topic:create($topic-name,$aws-key,$aws-secret);
                
                (: save the generated unique topic-ARN :)
                set $topic-arn := data($response//aws:TopicArn[text()]);
                
                (: AWS need some time to update the service :)
                util:sleep(1);
                
                (: list all existing topics and save them for comparison :)
                set $topic-list := topic:list($aws-key,$aws-secret);
                
                (: check if the created topic is in this list :)
                let $exists := $topic-list//aws:Topics/aws:member/aws:TopicArn[text() eq $topic-arn]
                return 
                
                    if($exists)
                    then
                        block {
                            set $success := true();
                            set $msg := "Topic successfully created.";
                        }        
                    else
                        set $msg := ("Topic was not created. Topic-list: ",$topic-list//aws:Topics/aws:member/aws:TopicArn[text()];);
            }
            else 
                set $msg := "Topic was not created because the Topic-Name already exists";

                
    } catch * ($code,$message,$obj) { 
        set $msg := error:to-string($code,$message,$obj);
    };
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                        <topicARN>{$topic-arn}</topicARN>
                    </particular_test>
    ) as last into $testresult;
    $testresult;
};

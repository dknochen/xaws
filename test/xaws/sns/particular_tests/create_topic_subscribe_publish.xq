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
module namespace test = 'http://test/xaws/sns/particular_tests/create_topic_subscribe_publish';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "sns_create_topic";
    variable $topic-name := string($testconfig/topic-name/text());
    variable $aws-key := string($testconfig/aws-key/text());
    variable $aws-secret := string($testconfig/aws-secret/text());
    
    variable $response;
    variable $topic-arn := "";
    variable $topic-list;
    
    try {
        (: Try to get the unique topic-ARN by the given topic-name :)
        $topic-arn := topic:get-topicARN-by-topicName($topic-name,$aws-key,$aws-secret);
        
        (: if there´s no topic-ARN, the given topic-name does not exist already :)
        if(not($topic-arn))
        then
            {
                
                (: create a topic :)
                variable $topic-arn := topic:create($aws-key,
                                                   $aws-secret,
                                                   $topic-name)[2]//sns:TopicArn/text();
                
                (: subscribe :)
                topic:subscribe($aws-key, 
                                $aws-secret, 
                                $topic-arn, 
                                "email", 
                                "dennis@XQuery.me");
        
                (: publish a message :)
                topic:publish($aws-key, 
                              $aws-secret, 
                              $topic-arn, 
                              "Hello World", 
                              "This is a test message");
                
                
                (: save the generated unique topic-ARN :)
                $topic-arn := data($response//aws:TopicArn[text()]);
                
                (: AWS need some time to update the service :)
                util:sleep(1);
                
                (: list all existing topics and save them for comparison :)
                $topic-list := topic:list($aws-key,$aws-secret);
                
                (: check if the created topic is in this list :)
                let $exists := $topic-list//aws:Topics/aws:member/aws:TopicArn[text() eq $topic-arn]
                return 
                
                    if($exists)
                    then
                        {
                            $success := true();
                             $msg := "Topic successfully created.";
                        }        
                    else
                        $msg := ("Topic was not created. Topic-list: ",$topic-list//aws:Topics/aws:member/aws:TopicArn[text()]);
            }
            else 
                $msg := "Topic was not created because the Topic-Name already exists";

                
    } catch * { 
        $msg := error:to-string($err:code,$err:description,$err:value);
    }
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                        <topicARN>{$topic-arn}</topicARN>
                    </particular_test>
    ) as last into $testresult;
    $testresult
};

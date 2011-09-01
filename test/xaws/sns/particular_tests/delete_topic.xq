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
 :      This test deletes a topic
 :      Note: In AWS, the function "DeleteTopic" is idempotent. That means, deleting a topic that not exists
 :            will not result in an error. To assure that this test only have a positive result if the topic 
 :            was really deleted, this test first will verify that the topic exists in AWS.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/delete_topic';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "sns_delete_topic";
    variable $aws-key := string($testconfig/aws-key/text());
    variable $aws-secret := string($testconfig/aws-secret/text());
    variable $topic-arn := string($testconfig/topic-arn/text());
    variable $topic-list;
    
    try {
        (: list all existing topics and save them for comparison :)
        $topic-list := topic:list($aws-key,$aws-secret);
        
        (: check if the topic the user want to delete is in the list :)
        let $exists := $topic-list//aws:Topics/aws:member/aws:TopicArn[text() eq $topic-arn]
        return 
            if($exists)
            then
                {
                    topic:delete($aws-key,$aws-secret, $topic-arn);
                    
                    (: AWS need some time to update the service :)
                    util:sleep(1);
                    
                     $topic-list := topic:list($aws-key,$aws-secret);
                    let $exists := $topic-list//aws:Topics/aws:member/aws:TopicArn[text() eq $topic-arn]
                    return 
                        if(not($exists))
                        then
                             {
                                $success := true();
                                $msg := "Topic successfully deleted";
                            }
                        else 
                             $msg := ("Topic was not deleted: ",$topic-list//aws:Topics/aws:member/aws:TopicArn[text()]);
                }
            else
                 $msg := ("Topic was not not found. Topic-list: ", $topic-list//aws:Topics/aws:member/aws:TopicArn[text()]);

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

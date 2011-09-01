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
 :      This test sends a message to all of a topic's subscribed endpoints.
 :
 :      NOTE: When a messageId is returned, the message has been saved and 
 :            Amazon SNS will attempt to deliver it to the topic's 
 :            subscribers shortly. The format of the outgoing message to 
 :            each subscribed endpoint depends on the notification protocol 
 :            selected.
 :      
 :
 :      CONSTRAINTS:
 :          - $message: Messages must be UTF-8 encoded strings at most 8 KB 
 :                      in size (8192 bytes, not 8192 characters).
 :          - $subject: Subjects must be ASCII text that begins with a 
 :                      letter, number or punctuation mark; must not include 
 :                      line breaks or control characters; and must be less 
 :                      than 100 characters long.
 :      
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/publish';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "sns_publish";
    
    variable $aws-key := string($testconfig/aws-key/text());
    variable $aws-secret := string($testconfig/aws-secret/text());
    variable $topic-arn := string($testconfig/topic-arn/text());
    variable $message := string($testconfig/message/text());
    variable $subject := string($testconfig/subject/text());
        
    variable $response;
    
    try {
        
        (: send the message :)
         $response := topic:publish($aws-key, $aws-secret, $topic-arn, $message, $subject);
        
        (: Only if an MessageID is returned, AWS will try to deliver the message shortly :)
        if (data($response//aws:MessageId[text()]))
        then
            {
                $success := true();
                $msg := "MessageID created and AWS will try to deliver the message shortly";
            }
        else
            $msg := "MessageID wasn´t created, the message won´t be published";
                
    } catch * { 
        $msg := error:to-string($err:code,$err:description,$err:value);
    }
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                    </particular_test>
    ) as last into $testresult;
    $testresult
};

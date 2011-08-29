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

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    declare $success := false();
    declare $msg := ();
    declare $testname := "sns_publish";
    
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    declare $topic-arn := string($testconfig/topic-arn/text());
    declare $message := string($testconfig/message/text());
    declare $subject := string($testconfig/subject/text());
        
    declare $response;
    
    try {
        
        (: send the message :)
        set $response := topic:publish($aws-key, $aws-secret, $topic-arn, $message, $subject);
        
        (: Only if an MessageID is returned, AWS will try to deliver the message shortly :)
        if (data($response//aws:MessageId[text()]))
        then
            block {
                set $success := true();
                set $msg := "MessageID created and AWS will try to deliver the message shortly";
            }
        else
            set $msg := "MessageID wasn´t created, the message won´t be published";
                
    } catch * ($code,$message,$obj) { 
        set $msg := error:to-string($code,$message,$obj);
    };
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                    </particular_test>
    ) as last into $testresult;
    $testresult;
};

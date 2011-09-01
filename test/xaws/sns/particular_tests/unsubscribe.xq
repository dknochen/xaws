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
 :      This test deletes a subscription
 :
 :      NOTE: If the subscription requires authentication for deletion, 
 :            only the owner of the subscription or the its topic's owner 
 :            can unsubscribe, and an AWS signature is required. If the 
 :            Unsubscribe call does not require authentication and the 
 :            requester is not the subscription owner, a final 
 :            cancellation message is delivered to the endpoint, so that 
 :            the endpoint owner can easily resubscribe to the topic if 
 :            the Unsubscribe request was unintended.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/unsubscribe';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "sns_unsubscribe";
    
    variable $aws-key := string($testconfig/aws-key/text());
    variable $aws-secret := string($testconfig/aws-secret/text());
    variable $subscription-arn := string($testconfig/subscription-arn/text());
    
    try {
        
        (: unsubscribe :)
        topic:unsubscribe($aws-key, $aws-secret, $subscription-arn);
        
        $success := true();
        $msg := "The endpoint was successfully unsubscribed";
                
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

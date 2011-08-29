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
 :      This test completes an earlier subscriber action by validating the token sent to the endpoint
 :      via the choosen protocol.
 :      
 :      NOTE: This test is using the unsigned request do validate an endpoint with the effect, that you
 :            can use the unauthenticated unsubscriber action (otherwise you have to authenticate yourself
 :            if you want to unsubscribe again)
 :      NOTE: Even if an earlier Subscriber action is validated already, AWS will return an positive 
 :            result message. This test will react the same way.
 :      NOTE: Confirmation tokens are valid for 24 hours.
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/confirm_subscription';

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
    declare $testname := "sns_confirm_subscription";
    
    declare $conf-token := string($testconfig/conf-token/text());
    declare $topic-arn := string($testconfig/topic-arn/text());
    declare $subscription-arn := "";
    declare $response;
    
    try {
        
        (: send the ConfirmationToken :)
        set $response := topic:confirm-subscription($topic-arn, $conf-token);
        
        (: save the generated unique subscription-ARN :)
        set $subscription-arn := data($response//aws:SubscriptionArn[text()]);
        
        set $success := true();
        set $msg := "Subscription confirmed successfully";
                
    } catch * ($code,$message,$obj) { 
        set $msg := error:to-string($code,$message,$obj);
    };
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                        <subscriptionARN>{$subscription-arn}</subscriptionARN>
                    </particular_test>
    ) as last into $testresult;
    $testresult;
};

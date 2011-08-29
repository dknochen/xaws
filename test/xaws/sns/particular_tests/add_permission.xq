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
 :      This test adds a statement to a topic's access control policy, 
 :      granting access for the specified AWS account to the specified action.
 :
 :      NOTE: The param $label must be UNIQUE! Otherwise, AWS can´t create it
 :            and this test will fail.
 :
 :      NOTE: Valid values for the parameter $action-name are:
 :          - "Publish",
 :          - "RemovePermission",
 :          - "SetTopicAttributes",
 :          - "DeleteTopic",
 :          - "ListSubscriptionsByTopic",
 :          - "GetTopicAttributes",
 :          - "Receive",
 :          - "AddPermission",
 :          - "Subscribe"
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/add_permission';

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
    declare $testname := "sns_add_permission";
    
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    declare $topic-arn := string($testconfig/topic-arn/text());
    declare $label := string($testconfig/label/text());
    declare $aws-account-id := string($testconfig/aws-account-id/text());
    declare $action-name := string($testconfig/action-name/text());
    
    try {
        
        (: add permission :)
        topic:add-permission($aws-key, $aws-secret, $topic-arn, $label, $action-name ,$aws-account-id);
        
        set $success := true();
        set $msg := "The permission was successfully added";
                
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

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
 :      This test returns a (limited) list of the requesters topics.
 :
 :      NOTE: The result list is limited by AWS. If there are more topics, a next-token is also returned and
 :      can be used in a new call of ListTopics to get further results.
 :      This test will only return the first part of the list.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/list_topics';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error';

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "sns_list_topics";
    variable $aws-key := string($testconfig/aws-key/text());
    variable $aws-secret := string($testconfig/aws-secret/text());
    
    try {
        (: list all topics :)
        let $result := topic:list($aws-key,$aws-secret)[2]
        
        return 
            (: save the (formatted) list in the testresult-message :)
            $msg := $result//aws:Topics/aws:member/aws:TopicArn[text()];
            $success := true();
            
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

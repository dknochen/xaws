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
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/s3/particular_tests/buckets_list';

import module namespace bucket = 'http://www.xquery.me/modules/xaws/s3/bucket';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error';
import module namespace config = "http://www.xquery.me/modules/xaws/s3/config";

import module namespace http = "http://expath.org/ns/http-client";

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace zerr = "http://www.zorba-xquery.com/errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "buckets_list";
    variable $aws-config := config:create($testconfig/aws-key/text(),$testconfig/aws-secret/text());
    
    try {
        (: list all buckets of the user :)
        let $result := bucket:list($aws-config)
        return
            if($result/aws:ListAllMyBucketsResult)
            then
                $success := true();
            else 
                $msg := ("Response is no ListAllMyBucketsResult: ",$result);

    } catch * { 
        $msg := error:to-string(
                  $err:code,
                  $err:description,
                  $err:value,
                  $err:module,
                  $err:line-number,
                  $err:column-number,
                  $zerr:stack-trace);
    }
    
    insert node <test name="{$testname}" success="{$success}">{$msg}</test> as last into $testresult;
    $testresult
};

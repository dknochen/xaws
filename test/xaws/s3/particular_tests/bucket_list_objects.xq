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
module namespace test = 'http://test/xaws/s3/particular_tests/bucket_list_objects';

import module namespace bucket = 'http://www.xquery.me/modules/xaws/s3/bucket' at '../../../../../uk/co/xquery/www/modules/xaws/s3/bucket.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '../../../../../uk/co/xquery/www/modules/xaws/helpers/error.xq';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    declare $success := false();
    declare $msg := ();
    declare $testname := "bucket_list_objects";
    declare $bucket-name := "test.XQuery.me";
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    
    try {
        
        (: list bucket content :)
        let $result := bucket:list($aws-key,$aws-secret,$bucket-name)[2]
        return 
            if($result/aws:ListBucketResult)
            then
                set $success := true()
            else
                set $msg := ("No ListBucketResult was returned: ",$result);

    } catch * ($code,$message,$obj) { 
        set $msg := error:to-string($code,$message,$obj);
    };
    
    insert node <test name="{$testname}" success="{$success}">{$msg}</test> as last into $testresult;
    $testresult;
};
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
import module namespace bucket_create_delete = 'http://test/xaws/s3/particular_tests/bucket_create_delete' at "particular_tests/bucket_create_delete.xq";
import module namespace buckets_list = 'http://test/xaws/s3/particular_tests/buckets_list' at "particular_tests/buckets_list.xq";
import module namespace bucket_list_objects = 'http://test/xaws/s3/particular_tests/bucket_list_objects' at "particular_tests/bucket_list_objects.xq";
import module namespace object_write_read_copy = 'http://test/xaws/s3/particular_tests/object_write_read_copy' at "particular_tests/object_write_read_copy.xq";

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

(:
    set as interpreter arguments in run configuration, e.g.:
    -e "aws-key:=yourkey" -e "aws-secret:=yoursecret" 
:)
declare variable $aws-key as xs:string external;
declare variable $aws-secret as xs:string external;

declare variable $tests :=
    <tests>
        <bucket_create_delete run="false" />
        <buckets_list run="false" />
        <bucket_list_objects run="false" />
        <object_write_read_copy run="true" />
    </tests>;

declare variable $testconfig :=
    <config>
        <aws-key>{$aws-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
        <bucketname>test.XQuery.me</bucketname>
    </config>;

declare variable $testresult := <testresult />;

let $exec_code :=
    string-join( 
        for $test in $tests/element()[@run eq "true"]
        return concat( $test/local-name(), ":run($testconfig,$testresult); "),
        ""
    )
return
   eval {$exec_code};    

$testresult;

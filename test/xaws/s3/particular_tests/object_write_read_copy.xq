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
module namespace test = 'http://test/xaws/s3/particular_tests/object_write_read_copy';

import module namespace object = 'http://www.xquery.me/modules/xaws/s3/object' at '../../../../../uk/co/xquery/www/modules/xaws/s3/object.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '../../../../../uk/co/xquery/www/modules/xaws/helpers/error.xq';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    declare $success := false();
    declare $msg := ();
    declare $testname := "object_write_read";
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    declare $bucketname := string($testconfig/bucketname/text());
    
    declare $xmlkey := "test.xml";
    declare $xmlkeycopy := "test2.xml";
    declare $textkey := "test.txt"; 
    declare $xmldata := <test><content a="huhu">Hello World</content></test>;
    declare $textdata := "Hello 
    
    World";
        
    (: check writing text data :)
    object:write($aws-key,$aws-secret,$bucketname,$textkey,$textdata);
    let $result := object:read($aws-key,$aws-secret,$bucketname,$textkey)[2]
    return
        if($result eq $textdata)
        then
            block{
                set $success := true();
                set $msg := ($msg,
                        <write_read_text success="true" />
                    );
            }
        else 
            block{
                set $success := false();
                set $msg := ($msg,
                    <write_read_text>
                        <msg>The returned text does not match the original text:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$textdata}</orig>
                    </write_read_text>);
            };
            
    (: check writing xml data :)
    object:write($aws-key,$aws-secret,$bucketname,$xmlkey,$xmldata);
    let $result := object:read($aws-key,$aws-secret,$bucketname,$xmlkey)[2]
    return
        if(deep-equal($result,$xmldata))
        then
            block{
                set $msg := ($msg,
                        <write_read_xml success="true" />
                    );
                
            }
        else 
            block{
                set $success := false();
                set $msg := ($msg,
                    <write_read_xml>
                        <msg>The returned xml does not match the original xml:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$xmldata}</orig>
                    </write_read_xml>);
            };
    
    (: check copy object :)
    object:copy($aws-key,$aws-secret,$bucketname,$xmlkey,$xmlkeycopy);
    let $result := object:read($aws-key,$aws-secret,$bucketname,$xmlkeycopy)[2]
    return
        if(deep-equal($result,$xmldata))
        then
            block{
                set $msg := ($msg,
                        <copy_xml success="true" />
                    );
                
            }
        else 
            block{
                set $success := false();
                set $msg := ($msg,
                    <copy_xml>
                        <msg>The returned xml of the copied object does not match the original xml:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$xmldata}</orig>
                    </copy_xml>);
            };
    
    insert node <test name="{$testname}" success="{$success}">{$msg}</test> as last into $testresult;
    $testresult;
};

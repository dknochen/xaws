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

import module namespace object = 'http://www.xquery.me/modules/xaws/s3/object';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error';
import module namespace config = "http://www.xquery.me/modules/xaws/s3/config";
import module namespace factory = 'http://www.xquery.me/modules/xaws/s3/factory';

import module namespace http = "http://expath.org/ns/http-client";

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";

declare %ann:sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    variable $success := false();
    variable $msg := ();
    variable $testname := "object_write_read";
    variable $aws-config := config:create($testconfig/aws-key/text(),$testconfig/aws-secret/text());
    variable $bucketname := string($testconfig/bucketname/text());
    
    variable $xmlkey := "test.xml";
    variable $xmlkeycopy := "test2.xml";
    variable $textkey := "test.txt"; 
    variable $xmldata := <test><content a="huhu">Hello World</content></test>;
    variable $textdata := "Hello 
    
    World";
        
    (: check writing text data :)
    object:write($aws-config,
                 factory:s3-object($textkey,$bucketname, (), (),$textdata),
                 ()
                 );
    let $result := object:read($aws-config,
                               factory:s3-object($textkey, $bucketname))[2]/object:content/node()
    return
        if($result eq $textdata)
        then
            {
                $success := true();
                $msg := ($msg,
                        <write_read_text success="true" />
                    );
            }
        else 
            {
                $success := false();
                $msg := ($msg,
                    <write_read_text>
                        <msg>The returned text does not match the original text:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$textdata}</orig>
                    </write_read_text>);
            }
            
    (: check writing xml data :)
    object:write($aws-config,
                 factory:s3-object($xmlkey,$bucketname, (), (),$xmldata),
                 ()
                 );
    let $result := object:read($aws-config,
                               factory:s3-object($xmlkey,$bucketname))[2]/object:content/node()
    return
        if(deep-equal($result,$xmldata))
        then
            {
                $msg := ($msg,
                        <write_read_xml success="true" />
                    );
                
            }
        else 
            {
                $success := false();
                $msg := ($msg,
                    <write_read_xml>
                        <msg>The returned xml does not match the original xml:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$xmldata}</orig>
                    </write_read_xml>);
            }
   
    (: check copy object 
    object:copy($aws-key,$aws-secret,$bucketname,$xmlkey,$xmlkeycopy);
    let $result := object:read($aws-key,$aws-secret,$bucketname,$xmlkeycopy)[2]
    return
        if(deep-equal($result,$xmldata))
        then
            {
                $msg := ($msg,
                        <copy_xml success="true" />
                    );
                
            }
        else 
            {
                $success := false();
                $msg := ($msg,
                    <copy_xml>
                        <msg>The returned xml of the copied object does not match the original xml:</msg> 
                        <returned>{$result}</returned>
                        <orig>{$xmldata}</orig>
                    </copy_xml>);
            }:)
    
    insert node <test name="{$testname}" success="{$success}">{$msg}</test> as last into $testresult;
    $testresult
};

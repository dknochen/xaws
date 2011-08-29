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
 :      This test-file will allow you to execute the particular tests you 
 :      want to run.
 :
 :      <b>IMPORTANT:</b>
 :      Due to the fact that some variables have to be set before executing 
 :      each test, please refer to each particular test you want to run first,
 :      then customize the CONFIGURATION AREA below.
 :
 :
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
import module namespace create_domain = 'http://test/xaws/sdb/particular_tests/create_domain' at "particular_tests/create_domain.xq";  
import module namespace list_domains = 'http://test/xaws/sdb/particular_tests/list_domains' at "particular_tests/list_domains.xq"; 
import module namespace domain_metadata = 'http://test/xaws/sdb/particular_tests/domain_metadata' at "particular_tests/domain_metadata.xq"; 
import module namespace put_attributes = 'http://test/xaws/sdb/particular_tests/put_attributes' at "particular_tests/put_attributes.xq"; 
import module namespace get_attributes = 'http://test/xaws/sdb/particular_tests/get_attributes' at "particular_tests/get_attributes.xq"; 
import module namespace select = 'http://test/xaws/sdb/particular_tests/select' at "particular_tests/select.xq"; 
import module namespace delete_attributes = 'http://test/xaws/sdb/particular_tests/delete_attributes' at "particular_tests/delete_attributes.xq"; 
import module namespace batch_put_attributes = 'http://test/xaws/sdb/particular_tests/batch_put_attributes' at "particular_tests/batch_put_attributes.xq"; 
import module namespace batch_delete_attributes = 'http://test/xaws/sdb/particular_tests/batch_delete_attributes' at "particular_tests/batch_delete_attributes.xq"; 
import module namespace delete_domain = 'http://test/xaws/sdb/particular_tests/delete_domain' at "particular_tests/delete_domain.xq"; 

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

(:
********** CONFIGURATION AREA **********

    set as interpreter arguments in run configuration, e.g.:
    -e "aws-key:=yourkey" -e "aws-secret:=yoursecret" 
:)
declare variable $aws-key as xs:string external;
declare variable $aws-secret as xs:string external;

(:
    Set/change the following variables:
    
    IMPORTANT: Please refer to each partial test you want to execute
               to understand, what variables you have to set for 
               running it.
:)
declare variable $domain-name as xs:string := "TestDomain";
declare variable $item-name as xs:string := "item123";
declare variable $attributes :=
    <attributes>
        <attribute>
            <name>Color</name>         
            <value>blue</value>   
        </attribute>
        <attribute>
            <name>Size</name>         
            <value>S</value>
            <replace>true</replace>     
        </attribute>
    </attributes>;
declare variable $select-expression as xs:string := "select * from TestDomain";

(: @param $items This variable is just needed if you use BatchPutAttributes/BatchDeleteAttributes :)
declare variable $items :=
    <items>
        <item>
            <name>item234</name>
            <attributes>
                <attribute>
                    <name>Color</name>
                    <value>green</value>
                </attribute>
            </attributes>
        </item>
        <item>
            <name>item345</name>
            <attributes>
                <attribute>
                    <name>Color</name>
                    <value>red</value>
                </attribute>
                <attribute>
                    <name>Size</name>
                    <value>L</value>
                </attribute>
            </attributes>
        </item>
        <item>
            <name>item456</name>
            <attributes>
                <attribute>
                    <name>Color</name>
                    <value>black</value>
                </attribute>
            </attributes>
        </item>
    </items>;
    
(:
********** END OF CONFIGURATION AREA **********
:)

declare variable $success as xs:boolean := false();

declare variable $testconfig :=
    <config>
        <aws-key>{$aws-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
        <domain-name>{$domain-name}</domain-name>
        <item-name>{$item-name}</item-name>
        <item>{$attributes}</item>
        <select-expression>{$select-expression}</select-expression>
        {$items}
    </config>;

declare variable $testresult := <testresult />;

(: **************************************************************************************
   Choose the tests you want to run
:)

(: create a domain :)
create_domain:run($testconfig,$testresult);
        
(: list all domains :)
list_domains:run($testconfig,$testresult);

(: create/replace attributes :)
put_attributes:run($testconfig,$testresult);

(: list the attributes :)
get_attributes:run($testconfig,$testresult);

(: select a few attributes :)
(: select:run($testconfig,$testresult); :)

(: delete one attribute :)
(: set $attributes := 
    <attributes>
        <attribute>
            <name>Color</name>   
        </attribute>
    </attributes>;
replace node $testconfig/item with <item>{$attributes}</item>;
delete_attributes:run($testconfig,$testresult); :)

(: delete all attributes :)
(: delete nodes $testconfig/item;
delete_attributes:run($testconfig,$testresult); :)

(: list the metadata for the domain :)
(: domain_metadata:run($testconfig,$testresult); :)

(: batch put attributes :)
(: batch_put_attributes:run($testconfig,$testresult); :)

(: batch delete attributes :)
(: Specify what attributes/items you want to delete :)
(: replace node $testconfig/items with 
    <items>
        <item>
            <name>item234</name>
            <attributes>
                <attribute>
                    <name>Color</name>
                    <value>green</value>
                </attribute>
            </attributes>
        </item>
        <item>
            <name>item345</name>
            <attributes>
                <attribute>
                    <name>Color</name>
                    <value>red</value>
                </attribute>
                <attribute>
                    <name>Size</name>
                    <value>L</value>
                </attribute>
            </attributes>
        </item>
    </items>; 
batch_delete_attributes:run($testconfig,$testresult); :)

(: delete a domain :)
delete_domain:run($testconfig,$testresult);

(: ************************************************************************************** :)

$testresult;

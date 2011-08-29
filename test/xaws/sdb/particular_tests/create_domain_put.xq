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
 :      This test creates a domain
 :
 :      NOTE: In AWS, the function "CreateDomain" is idempotent. That means, AWS will also give a 
 :            positive result, if a domain with a similar name already exists and was not created 
 :            by this test (Domain-names have to be unique!) 
 :
 :      NOTE: The CreateDomain operation might take 10 or more 
 :            seconds to complete.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sdb/particular_tests/create_domain_put';

import module namespace domain = 'http://www.xquery.me/modules/xaws/sdb/domain' at '/uk/co/xquery/www/modules/xaws/sdb/domain.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://sdb.amazonaws.com/doc/2009-04-15/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    
    declare $domain := "MyStore";
    declare $aws-key := "...";
    declare $aws-secret := "...";
    
    (: create domain MyStore :)
    domain:create(
        $aws-key,$aws-secret,"MyStore");
    
    (: put item with attributes into domain :)
    domain:put-attributes(
        $aws-key,
        $aws-secret,
        "MyStore",
        "Sweater17",
        <attributes>
            <attribute>
                <name>color</name>         
                <value>black</value>   
            </attribute>
        </attributes>);
        
};

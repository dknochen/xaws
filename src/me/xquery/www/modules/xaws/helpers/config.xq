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
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace config = 'http://www.xquery.me/modules/xaws/helpers/config';

(:~
 : Create a configuration element that is used with an AWS request (S3, SDB, SNS ...).
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return an aws-config element that needs to be passed to most of the AWS Service functions
:)
declare function config:create (
    $aws-access-key as xs:string, 
    $aws-secret as xs:string) as element(aws-config) {

    config:create($aws-access-key,$aws-secret,false())
};


(:~
 : Create a configuration element that is used with an AWS request (S3, SDB, SNS ...).
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $use-https Defines whether to connect to AWS through https (true) or http (false)
 : @return an aws-config element that needs to be passed to most of the AWS Service functions
:)
declare function config:create (
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $use-https as xs:boolean) as element(aws-config) {

    <aws-config>
        <aws-key>{$aws-access-key}</aws-key>
        <aws-secret>{$aws-secret}</aws-secret>
        <use-https>{$use-https}</use-https>
    </aws-config>
};

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
module namespace s3_config = 'http://www.xquery.me/modules/xaws/s3/config';

import module namespace config = 'http://www.xquery.me/modules/xaws/helpers/config';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';

(:~
 : Create a configuration element that is used for S3 requests.
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return an aws-config element that needs to be passed to most of the AWS Service functions
 : @return an aws-config element that needs to be passed to most of the S3 Service functions
:)
declare function s3_config:create (
    $aws-access-key as xs:string, 
    $aws-secret as xs:string) as element(aws-config) {

    config:create($aws-access-key,$aws-secret,false())
};


(:~
 : Create a configuration element that is used for S3 requests.
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return an aws-config element that needs to be passed to most of the S3 Service functions
:)
declare function s3_config:create (
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $use-https as xs:boolean) as element(aws-config) {

    config:create($aws-access-key,$aws-secret,$use-https)
};


(:~
 : This function sets a default context bucket for S3 calls.
 :
 : @param $aws-config the main configuration for interfacing with AWS 
 : @param $bucket-name the main context bucket used if no explicit bucket-name is passed to an S3 function
:)
declare updating function s3_config:set-context-bucket (
    $aws-config as element(aws-config),
    $bucket-name as xs:string){
    utils:insert-replace($aws-config, <context-bucket>{$bucket-name}</context-bucket>)
};


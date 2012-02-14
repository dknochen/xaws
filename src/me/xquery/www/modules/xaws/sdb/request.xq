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
 :      Contains functions to create a request.
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace request = 'http://www.xquery.me/modules/xaws/sdb/request';

import module namespace common_request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace error = 'http://www.xquery.me/modules/xaws/sdb/error';

import module namespace http = "http://expath.org/ns/http-client";

declare namespace ann = "http://www.zorba-xquery.com/annotations";


(:~
 : send an http request and return the response which is usually a pair of two items: One item containing the response
 : headers, status code,... and one item representing the response body (if any).
 :
 : @return the http response
:)
declare %ann:sequential function request:send(
    $aws-config as element(aws-config),
    $request as element(http:request),
    $parameters as element(parameter)*) as item()* {

    (: sign the request :)
    common_request:sign-v2(
        $request,
        "sdb.amazonaws.com",
        "/",
        "2009-04-15",
        $parameters,
        string($aws-config/aws-key/text()),
        string($aws-config/aws-secret/text()));
                
    let $response := http:send-request($request)
    let $status := number($response[1]/@status)
    return
        
        if($status = (200,204)) 
        then $response
        else error:throw($status,$response)
};


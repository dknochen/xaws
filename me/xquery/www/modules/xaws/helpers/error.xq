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
module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace base64 = "http://www.zorba-xquery.com/modules/converters/base64";

(: locales :)
declare variable $error:LOCALE_EN as xs:string := "en_EN";

declare variable $error:LOCALE_DEFAULT as xs:string := $error:LOCALE_EN;

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $error:CONNECTION_FAILED as xs:QName := xs:QName("error:CONNECTION_FAILED");

(: Error messages :)
declare variable $error:messages :=
    <error:messages>
      <error:CONNECTION_FAILED locale="{$error:LOCALE_EN}" param="0" http-code="-1" code="CONNECTION_FAILED" http-error="-1 Request Failed">
        The HTTP/HTTPS connection of the http-client failed. Please, check connectability and/or proxy settings if any.
      </error:CONNECTION_FAILED>
    </error:messages>;

(:~
 :  Throws an error with the default locale.
 : 
:)
declare function error:throw(
                    $http_code as xs:double, 
                    $http_response as item()*,
                    $error_messages as element()) {

    error:throw($http_code, $http_response, $error:LOCALE_DEFAULT,$error_messages)
};


declare function error:throw(
                    $http_code as xs:double, 
                    $http_response as item()*,
                    $locale as xs:string,
                    $error_messages as element()) {

    let $error_obj := 
        if(empty($http_response[2]))
        then $http_response[1] 
        else 
            typeswitch ($http_response[2])
                case $resp as document-node() 
                    return 
                        if($http_response[2]/Error)
                        then $http_response[2]/Error
                        else $http_response[2]
                case $resp as xs:base64Binary 
                    return 
                        base64:decode($http_response[2])
                default $resp return $http_response[2]
            
    let $error_code :=
        if($http_code eq -1)
        then "CONNECTION_FAILED" 
        else $error_obj/Code/text()
    let $message_node as element()? := 
        let $temp := error:get_message ($error_code, $http_code, $locale,$error_messages)
        return
            if($temp)
            then $temp
            else error:get_message ($error_code, $http_code, $locale,$error:messages)
    let $description as xs:string := 
        if($message_node)
        then concat("AWS Error returned: ", 
                let $http-error := $message_node/@http-error
                return if ($http-error) then concat(string($http-error),". Reason: ")else "",
                $message_node/text())
        else "An unexpected error happened. Please, investigate the error object for more details."
    let $error_qname as xs:QName := 
        if($message_node)
        then node-name($message_node)
        else xs:QName("error:UNEXPECTED_ERROR")
    
    let $eo := fn:serialize($error_obj)
    return 
        error($error_qname,$description,trace($error_obj,"ERROROBJ: "))
};


declare function error:get_message (
        $error_code as xs:string?, 
        $http_code as xs:double, 
        $locale as xs:string,
        $error_messages as element()) as element()? {
    let $temp_node := $error_messages/element()[@code=$error_code][@locale=$locale]
    let $node := 
            if($temp_node) 
            then $temp_node 
            else 
                let $temp_node := $error_messages/element()[number(@http-code)=$http_code][@locale=$locale]
                return
                    if(count($temp_node) eq 1) 
                    then $temp_node
                    else 
                        if($locale eq $error:LOCALE_DEFAULT)
                        then ()
                        else error:get_message($error_code,$http_code,$error:LOCALE_DEFAULT,$error_messages)
    return $node
};


declare function error:to-string($code,$message,$obj) as xs:string {
    let $msgs := 
        ( 
            concat("Errorcode: " , $code),
            concat("Errormessage: ", $message),
            if($obj)
            then concat( "Errorobject: ", fn:serialize($obj))
            else "Errorobject: ()"
        )
    return string-join($msgs,"&#10;")
};


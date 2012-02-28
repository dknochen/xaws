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
module namespace common_err = 'http://www.xquery.me/modules/xaws/helpers/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace base64 = "http://www.zorba-xquery.com/modules/converters/base64";

declare namespace zerr = "http://www.zorba-xquery.com/errors";

(: locales :)
declare variable $common_err:LOCALE_EN as xs:string := "en_EN";

declare variable $common_err:LOCALE_DEFAULT as xs:string := $common_err:LOCALE_EN;

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $common_err:CONNECTION_FAILED as xs:QName := xs:QName("common_err:CONNECTION_FAILED");

(: Error messages :)
declare variable $common_err:messages :=
    <common_err:messages>
      <common_err:CONNECTION_FAILED locale="{$common_err:LOCALE_EN}" param="0" http-code="-1" code="CONNECTION_FAILED" http-error="-1 Request Failed">
        The HTTP/HTTPS connection of the http-client failed. Please, check connectability and/or proxy settings if any.
      </common_err:CONNECTION_FAILED>
    </common_err:messages>;

(:~
 :  Throws an error with the default locale.
 : 
:)
declare function common_err:throw(
                    $http_code as xs:double, 
                    $http_response as item()*,
                    $error_messages as element()) {

    common_err:throw($http_code, $http_response, $common_err:LOCALE_DEFAULT,$error_messages)
};


declare function common_err:throw(
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
                      switch (true())
                        case ($http_response[2]/*:ErrorResponse/*:Error) return $http_response[2]/*:ErrorResponse/*:Error
                        case ($http_response[2]/Error) return $http_response[2]/Error
                        default return $http_response[2]
                case $resp as xs:base64Binary 
                    return 
                        base64:decode($http_response[2])
                default $resp return $http_response[2]
            
    let $error_code :=
        if($http_code eq -1)
        then "CONNECTION_FAILED" 
        else $error_obj//*:Code/text()
    let $message_node as element()? := 
        let $temp := common_err:get_message ($error_code, $http_code, $locale,$error_messages)
        return
            if($temp)
            then $temp
            else common_err:get_message ($error_code, $http_code, $locale,$common_err:messages)
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
        else xs:QName("common_err:UNEXPECTED_ERROR")
    
    let $eo := fn:serialize($error_obj,
      <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
        <output:method value="xml"/>
        <output:version value="1.0"/>
        <output:indent value="yes"/>
        <output:omit-xml-declaration value="yes"/>
      </output:serialization-parameters>)
    return 
        error($error_qname,$description, $error_obj)
};


declare function common_err:get_message (
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
                        if($locale eq $common_err:LOCALE_DEFAULT)
                        then ()
                        else common_err:get_message($error_code,$http_code,$common_err:LOCALE_DEFAULT,$error_messages)
    return $node
};


declare function common_err:to-string($code,$message,$obj,$module,$line-no,$col-no,$stacktrace) as xs:string {
    let $msgs := 
        ( 
            concat("Errorcode: " , $code),
            concat("Errormessage: ", $message),
            concat("Module: " , $module, " (", $line-no, ":", $col-no,")"),
            if($obj)
            then concat( "Errorobject: ", fn:serialize($obj))
            else "Errorobject: ()",
            "Stacktrace: ",
            for $entry in $stacktrace/zerr:entry
            let $function := concat("{",$entry/zerr:function/@namespace,"}:",$entry/zerr:function/@localname,
                                    "#",$entry/zerr:function/@arity)
            let $location := concat($entry/zerr:location/@name,":",
                                    if($entry/zerr:location/@line-begin eq $entry/zerr:location/@line-end)
                                    then
                                      $entry/zerr:location/@line-begin
                                    else
                                      concat($entry/zerr:location/@line-begin,"-",$entry/zerr:location/@line-end),
                                    ";c",$entry/zerr:location/@column-begin,"-",$entry/zerr:location/@column-end)
            return  
              concat($location, " ", $function)
        )
    return string-join($msgs,"&#10;")
};

declare function common_err:serialize($obj as item()*) as xs:string
{
  serialize($obj,
    <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
      <output:omit-xml-declaration value="yes" />
      <output:method value="xml" />
      <output:indent value="yes" />
    </output:serialization-parameters>
  )
};

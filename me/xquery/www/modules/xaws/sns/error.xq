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
 :      Implementation of Error Messages returned from SNS. 
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace error = 'http://www.xquery.me/modules/xaws/sns/error';

import module namespace common_error = 'http://www.xquery.me/modules/xaws/helpers/error' at '../helpers/error.xq';

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $error:AUTHORIZATIONERROR as xs:QName := xs:QName("error:AUTHORIZATIONERROR");
declare variable $error:INTERNALERROR as xs:QName := xs:QName("error:INTERNALERROR");
declare variable $error:INVALIDPARAMETER as xs:QName := xs:QName("error:INVALIDPARAMETER");
declare variable $error:NOTFOUND as xs:QName := xs:QName("error:NOTFOUND");
declare variable $error:SUBSCRIPTIONLIMITEXCEEDED as xs:QName := xs:QName("error:SUBSCRIPTIONLIMITEXCEEDED");
declare variable $error:TOPICLIMITEXCEEDED as xs:QName := xs:QName("error:TOPICLIMITEXCEEDED");


(: Error messages :)
declare variable $error:messages :=
    <error:messages xmlns:err="http://www.xquery.me/modules/xaws/sns/error">
      <error:AUTHORIZATIONERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AuthorizationError" http-error="403 Forbidden">Indicates that the user has been denied access to the requested resource.</error:AUTHORIZATIONERROR>
      <error:INTERNALERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="500" code="InternalError" http-error="500 Internal Server Error">Indicates an internal service error.</error:INTERNALERROR>
      <error:INVALIDPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameter" http-error="400 Bad Request">Indicates that a request parameter does not comply with the associated constraints.</error:INVALIDPARAMETER>
      <error:NOTFOUND locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NotFound" http-error="404 Not Found">Indicates that the requested resource does not exist.</error:NOTFOUND>
      <error:SUBSCRIPTIONLIMITEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="SubscriptionLimitExceeded" http-error="403 Forbidden">Indicates that the customer already owns the maximum allowed number of subscriptions.</error:SUBSCRIPTIONLIMITEXCEEDED>
      <error:TOPICLIMITEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="TopicLimitExceeded" http-error="403 Forbidden">Indicates that the customer already owns the maximum allowed number of topics.</error:TOPICLIMITEXCEEDED>
    </error:messages>;


(:~
 :  Throws an error with the default locale.
 : 
:)
declare function error:throw(
                    $http_code as xs:double, 
                    $http_response as item()*) {

    common_error:throw($http_code, $http_response, $common_error:LOCALE_DEFAULT,$error:messages)
};


declare function error:throw(
                    $http_code as xs:double, 
                    $http_response as item()*,
                    $locale as xs:string) {

    common_error:throw($http_code, $http_response, $locale,$error:messages)
};


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
 :      Implementation of Error Messages returned from IAM. 
 : </p>
 :
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 : @author Alexander Kreutz alexander [dot] kreutz [at] 28msec [dot] com
:)
module namespace error = 'http://www.xquery.me/modules/xaws/iam/error';

import module namespace common_error = 'http://www.xquery.me/modules/xaws/helpers/error';

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $error:AUTHORIZATIONERROR as xs:QName := xs:QName("error:AUTHORIZATIONERROR");
declare variable $error:INTERNALERROR as xs:QName := xs:QName("error:INTERNALERROR");
declare variable $error:INVALIDPARAMETER as xs:QName := xs:QName("error:INVALIDPARAMETER");
declare variable $error:NOTFOUND as xs:QName := xs:QName("error:NOTFOUND");
declare variable $error:SUBSCRIPTIONLIMITEXCEEDED as xs:QName := xs:QName("error:SUBSCRIPTIONLIMITEXCEEDED");
declare variable $error:TOPICLIMITEXCEEDED as xs:QName := xs:QName("error:TOPICLIMITEXCEEDED");


(: Error messages :)
declare variable $error:messages :=
    <error:messages>
    
      <!-- common errors http://docs.amazonwebservices.com/IAM/latest/APIReference/CommonErrors.html -->
      <error:INCOMPLETESIGNATURE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncompleteSignature" http-error="400 Bad Request">
        The request signature does not conform to AWS standards.</error:INCOMPLETESIGNATURE>
      <error:INTERNALFAILURE locale="{$common_error:LOCALE_EN}" param="0" http-code="500" code="InternalFailure" http-error="500 Internal Server Error">
        The request processing has failed due to some unknown error, exception or failure.</error:INTERNALFAILURE>
      <error:INVALIDACTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidAction" http-error="400 Bad Request">
        The action or operation requested is invalid.</error:INVALIDACTION>
      <error:INVALIDCLIENTTOKENID locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidClientTokenId" http-error="403 Forbidden">
        The X.509 certificate or AWS Access Key ID provided does not exist in our records.</error:INVALIDCLIENTTOKENID>
      <error:INVALIDPARAMETERCOMBINATION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterCombination" http-error="400 Bad Request">
        Parameters that must not be used together were used together.</error:INVALIDPARAMETERCOMBINATION>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">
        A bad or out-of-range value was supplied for the input parameter.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDQUERYPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidQueryParameter" http-error="400 Bad Request">
        AWS query string is malformed, does not adhere to AWS standards.</error:INVALIDQUERYPARAMETER>
      <error:MALFORMEDQUERYSTRING locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="MalformedQueryString" http-error="404 Not Found">
        The query string is malformed.</error:MALFORMEDQUERYSTRING>
      <error:MISSINGACTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingAction" http-error="400 Bad Request">
        The request is missing an action or operation parameter.</error:MISSINGACTION>
      <error:MISSINGAUTHENTICATIONTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="MissingAuthenticationToken" http-error="403 Forbidden">
        Request must contain either a valid (registered) AWS Access Key ID or X.509 certificate.</error:MISSINGAUTHENTICATIONTOKEN>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">
        An input parameter that is mandatory for processing the request is not supplied.</error:MISSINGPARAMETER>
      <error:OPTINREQUIRED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="OptInRequired" http-error="403 Forbidden">
        The AWS Access Key ID needs a subscription for the service.</error:OPTINREQUIRED>
      <error:REQUESTEXPIRED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestExpired" http-error="400 Bad Request">
        Request is past expires date or the request date (either with 15 minute padding), or the request date occurs more than 15 minutes in the future.
      </error:REQUESTEXPIRED>
      <error:SERVICEUNAVAILABLE locale="{$common_error:LOCALE_EN}" param="0" http-code="503" code="ServiceUnavailable" http-error="503 Service Temporarily Unavailable">
        The request has failed due to a temporary failure of the server.</error:SERVICEUNAVAILABLE>
      <error:THROTTLING locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="Throttling" http-error="400 Bad Request">
        Request was denied due to request throttling.</error:THROTTLING>
      
      <!-- CreateUser errors http://docs.amazonwebservices.com/IAM/latest/APIReference/API_CreateUser.html -->
      <error:ENTITYALREADYEXISTS locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="EntityAlreadyExists" http-error="409 Conflict">
        The request was rejected because it attempted to create a resource that already exists.</error:ENTITYALREADYEXISTS>
      <error:LIMITEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="LimitExceeded" http-error="409 Conflict">
        The request was rejected because it attempted to create resources beyond the current AWS account limits. 
        The error message describes the limit exceeded.</error:LIMITEXCEEDED>
      <error:NOSUCHENTITY locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchEntity" http-error="404 Not Found">
        The request was rejected because it referenced an entity that does not exist. 
        The error message describes the entity.</error:NOSUCHENTITY>
        
      <!-- DeleteGroup -->
      <error:DELETECONFLICT locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="DeleteConflict" http-error="409 Conflict">
         The request was rejected because it attempted to delete a resource that has attached subordinate entities. 
         The error message describes these entities.</error:DELETECONFLICT>
         
      <!-- DeleteLoginProfile -->
      <error:ENTITYTEMPORARILYUNMODIFIABLE locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="EntityTemporarilyUnmodifiable" http-error="409 Conflict">    
         The request was rejected because it referenced an entity that is temporarily unmodifiable, such as a user name that was deleted and then recreated. 
         The error indicates that the request is likely to succeed if you try again after waiting several minutes. 
         The error message describes the entity.</error:ENTITYTEMPORARILYUNMODIFIABLE>    
      
     <!-- STS errors -->
     <error:MALFORMEDPOLICYDOCUMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedPolicyDocument" http-error="400 Bad Request">
         The request was rejected because the policy document was malformed. The error message describes the specific error.</error:MALFORMEDPOLICYDOCUMENT>
     <error:PACKEDPOLICYTOOLARGE local="{$common_error:LOCALE_EN}" param="0" http-code="400" code="PackedPolicyTooLarge" http-error="400 Bad Request">
         The request was rejected because the policy document was too large. The error message describes how big the policy document is, in packed form, as a percentage of what the API allows.</error:PACKEDPOLICYTOOLARGE>
                      
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


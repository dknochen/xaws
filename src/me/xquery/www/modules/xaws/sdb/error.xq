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
 :      Implementation of Error Messages returned from SDB. 
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
:)
module namespace error = 'http://www.xquery.me/modules/xaws/sdb/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace common_error = 'http://www.xquery.me/modules/xaws/helpers/error';

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $error:UNEXPECTED_SDB_ERROR as xs:QName := xs:QName("error:UNEXPECTED_SDB_ERROR");
declare variable $error:CONNECTION_FAILED as xs:QName := xs:QName("error:CONNECTION_FAILED");
declare variable $error:ACCESSFAILURE as xs:QName := xs:QName("error:ACCESSFAILURE");
declare variable $error:ATTRIBUTEDOESNOTEXIST as xs:QName := xs:QName("error:ATTRIBUTEDOESNOTEXIST");
declare variable $error:AUTHFAILURE as xs:QName := xs:QName("error:AUTHFAILURE");
declare variable $error:AUTHMISSINGFAILURE as xs:QName := xs:QName("error:AUTHMISSINGFAILURE");
declare variable $error:CONDITIONALCHECKFAILED as xs:QName := xs:QName("error:CONDITIONALCHECKFAILED");
declare variable $error:EXISTSANDEXPECTEDVALUE as xs:QName := xs:QName("error:EXISTSANDEXPECTEDVALUE");
declare variable $error:FEATUREDEPRECATED as xs:QName := xs:QName("error:FEATUREDEPRECATED");
declare variable $error:INCOMPLETEEXPECTEDEXPRESSION as xs:QName := xs:QName("error:INCOMPLETEEXPECTEDEXPRESSION");
declare variable $error:INTERNALERROR as xs:QName := xs:QName("error:INTERNALERROR");
declare variable $error:INVALIDACTION as xs:QName := xs:QName("error:INVALIDACTION");
declare variable $error:INVALIDHTTPAUTHHEADER as xs:QName := xs:QName("error:INVALIDHTTPAUTHHEADER");
declare variable $error:INVALIDHTTPREQUEST as xs:QName := xs:QName("error:INVALIDHTTPREQUEST");
declare variable $error:INVALIDLITERAL as xs:QName := xs:QName("error:INVALIDLITERAL");
declare variable $error:INVALIDNEXTTOKEN as xs:QName := xs:QName("error:INVALIDNEXTTOKEN");
declare variable $error:INVALIDNUMBERPREDICATES as xs:QName := xs:QName("error:INVALIDNUMBERPREDICATES");
declare variable $error:INVALIDNUMBERVALUETESTS as xs:QName := xs:QName("error:INVALIDNUMBERVALUETESTS");
declare variable $error:INVALIDPARAMETERCOMBINATION as xs:QName := xs:QName("error:INVALIDPARAMETERCOMBINATION");
declare variable $error:INVALIDPARAMETERVALUE as xs:QName := xs:QName("error:INVALIDPARAMETERVALUE");
declare variable $error:INVALIDQUERYEXPRESSION as xs:QName := xs:QName("error:INVALIDQUERYEXPRESSION");
declare variable $error:INVALIDRESPONSEGROUPS as xs:QName := xs:QName("error:INVALIDRESPONSEGROUPS");
declare variable $error:INVALIDSERVICE as xs:QName := xs:QName("error:INVALIDSERVICE");
declare variable $error:INVALIDSOAPREQUEST as xs:QName := xs:QName("error:INVALIDSOAPREQUEST");
declare variable $error:INVALIDSORTEXPRESSION as xs:QName := xs:QName("error:INVALIDSORTEXPRESSION");
declare variable $error:INVALIDURI as xs:QName := xs:QName("error:INVALIDURI");
declare variable $error:INVALIDWSADDRESSINGPROPERTY as xs:QName := xs:QName("error:INVALIDWSADDRESSINGPROPERTY");
declare variable $error:INVALIDWSDLVERSION as xs:QName := xs:QName("error:INVALIDWSDLVERSION");
declare variable $error:MALFORMEDSOAPSIGNATURE as xs:QName := xs:QName("error:MALFORMEDSOAPSIGNATURE");
declare variable $error:MISSINGACTION as xs:QName := xs:QName("error:MISSINGACTION");
declare variable $error:MISSINGPARAMETER as xs:QName := xs:QName("error:MISSINGPARAMETER");
declare variable $error:MISSINGWSADDRESSINGPROPERTY as xs:QName := xs:QName("error:MISSINGWSADDRESSINGPROPERTY");
declare variable $error:MULTIPLEEXISTSCONDITIONS as xs:QName := xs:QName("error:MULTIPLEEXISTSCONDITIONS");
declare variable $error:MULTIPLEEXPECTEDNAMES as xs:QName := xs:QName("error:MULTIPLEEXPECTEDNAMES");
declare variable $error:MULTIPLEEXPECTEDVALUES as xs:QName := xs:QName("error:MULTIPLEEXPECTEDVALUES");
declare variable $error:MULTIVALUEDATTRIBUTE as xs:QName := xs:QName("error:MULTIVALUEDATTRIBUTE");
declare variable $error:NOSUCHDOMAIN as xs:QName := xs:QName("error:NOSUCHDOMAIN");
declare variable $error:NOSUCHVERSION as xs:QName := xs:QName("error:NOSUCHVERSION");
declare variable $error:NOTYETIMPLEMENTED as xs:QName := xs:QName("error:NOTYETIMPLEMENTED");
declare variable $error:NUMBERDOMAINSEXCEEDED as xs:QName := xs:QName("error:NUMBERDOMAINSEXCEEDED");
declare variable $error:NUMBERDOMAINATTRIBUTESEXCEEDED as xs:QName := xs:QName("error:NUMBERDOMAINATTRIBUTESEXCEEDED");
declare variable $error:NUMBERDOMAINBYTESEXCEEDED as xs:QName := xs:QName("error:NUMBERDOMAINBYTESEXCEEDED");
declare variable $error:NUMBERITEMATTRIBUTESEXCEEDED as xs:QName := xs:QName("error:NUMBERITEMATTRIBUTESEXCEEDED");
declare variable $error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED as xs:QName := xs:QName("error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED");
declare variable $error:NUMBERSUBMITTEDITEMSEXCEEDED as xs:QName := xs:QName("error:NUMBERSUBMITTEDITEMSEXCEEDED");
declare variable $error:REQUESTEXPIRED as xs:QName := xs:QName("error:REQUESTEXPIRED");
declare variable $error:REQUESTTIMEOUT as xs:QName := xs:QName("error:REQUESTTIMEOUT");
declare variable $error:SERVICEUNAVAILABLE as xs:QName := xs:QName("error:SERVICEUNAVAILABLE");
declare variable $error:TOOMANYREQUESTEDATTRIBUTES as xs:QName := xs:QName("error:TOOMANYREQUESTEDATTRIBUTES");
declare variable $error:UNSUPPORTEDHTTPVERB as xs:QName := xs:QName("error:UNSUPPORTEDHTTPVERB");
declare variable $error:UNSUPPORTEDNEXTTOKEN as xs:QName := xs:QName("error:UNSUPPORTEDNEXTTOKEN");
declare variable $error:URITOOLONG as xs:QName := xs:QName("error:URITOOLONG");


(: Error messages :)
declare variable $error:messages :=
    <error:messages xmlns:error="http://www.xquery.me/modules/xaws/sdb/error">
      <error:CONNECTION_FAILED locale="{$common_error:LOCALE_EN}" param="0" http-code="-1" code="" http-error="-1 Request Failed">The HTTP/HTTPS connection of the http-client failed.</error:CONNECTION_FAILED>
      <error:ACCESSFAILURE locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AccessFailure" http-error="403 Forbidden">Access to the resource " + resourceName + " is denied.</error:ACCESSFAILURE>
      <error:ATTRIBUTEDOESNOTEXIST locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="AttributeDoesNotExist" http-error="404 Not Found">Attribute ("+ name + ") does not exist</error:ATTRIBUTEDOESNOTEXIST>
      <error:AUTHFAILURE locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AuthFailure" http-error="403 Forbidden">AWS was not able to validate the provided access credentials.</error:AUTHFAILURE>
      <error:AUTHMISSINGFAILURE locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AuthMissingFailure" http-error="403 Forbidden">AWS was not able to authenticate the request: access credentials are missing.</error:AUTHMISSINGFAILURE>
      <error:CONDITIONALCHECKFAILED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="ConditionalCheckFailed" http-error="409 Conflict">Conditional check failed. Attribute (" + name + ") value exists.</error:CONDITIONALCHECKFAILED>
      <error:CONDITIONALCHECKFAILED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="ConditionalCheckFailed" http-error="409 Conflict">Conditional check failed. Attribute ("+ name +") value is ("+ value +") but was expected ("+ expValue +")</error:CONDITIONALCHECKFAILED>
      <error:EXISTSANDEXPECTEDVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="ExistsAndExpectedValue" http-error="400 Bad Request">Expected.Exists=false and Expected.Value cannot be specified together</error:EXISTSANDEXPECTEDVALUE>
      <error:FEATUREDEPRECATED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="FeatureDeprecated" http-error="400 Bad Request">The replace flag must be specified per attribute, not per item.</error:FEATUREDEPRECATED>
      <error:INCOMPLETEEXPECTEDEXPRESSION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncompleteExpectedExpression" http-error="400 Bad Request">If Expected.Exists=true or unspecified, then Expected.Value has to be specified</error:INCOMPLETEEXPECTEDEXPRESSION>
      <error:INTERNALERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="500" code="InternalError" http-error="500 Internal Server Error">Request could not be executed due to an internal service error.</error:INTERNALERROR>
      <error:INVALIDACTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidAction" http-error="400 Bad Request">The action " + actionName + " is not valid for this web service.</error:INVALIDACTION>
      <error:INVALIDHTTPAUTHHEADER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidHTTPAuthHeader" http-error="400 Bad Request">The HTTP authorization header is bad, use " + correctFormat".</error:INVALIDHTTPAUTHHEADER>
      <error:INVALIDHTTPREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidHttpRequest" http-error="400 Bad Request">The HTTP request is invalid. Reason: " + reason".</error:INVALIDHTTPREQUEST>
      <error:INVALIDLITERAL locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidLiteral" http-error="400 Bad Request">Illegal literal in the filter expression.</error:INVALIDLITERAL>
      <error:INVALIDNEXTTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidNextToken" http-error="400 Bad Request">The specified next token is not valid.</error:INVALIDNEXTTOKEN>
      <error:INVALIDNUMBERPREDICATES locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidNumberPredicates" http-error="400 Bad Request">Too many predicates in the query expression.</error:INVALIDNUMBERPREDICATES>
      <error:INVALIDNUMBERVALUETESTS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidNumberValueTests" http-error="400 Bad Request">Too many value tests per predicate in the query expression.</error:INVALIDNUMBERVALUETESTS>
      <error:INVALIDPARAMETERCOMBINATION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterCombination" http-error="400 Bad Request">The parameter " + param1 + " cannot be used with the parameter " + param2".</error:INVALIDPARAMETERCOMBINATION>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter MaxNumberOfDomains is invalid. MaxNumberOfDomains must be between 1 and 100.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter MaxNumberOfItems is invalid. MaxNumberOfItems must be between 1 and 2500.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter MaxNumberOfDomains is invalid. MaxNumberOfDomains must be between 1 and 100.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter " + paramName + " is invalid. " + reason".</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Name is invalid. Value exceeds maximum length of 1024.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Value is invalid. Value exceeds maximum length of 1024.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter DomainName is invalid.</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Replace is invalid. The Replace flag should be either trueor false</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Expected.Exists is invalid. Expected.Exists should be either trueor false</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Name is invalid.The empty string is an illegal attribute name</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter Value is invalid. Value exceeds maximum length of 1024</error:INVALIDPARAMETERVALUE>
      <error:INVALIDPARAMETERVALUE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidParameterValue" http-error="400 Bad Request">Value (" + value + ") for parameter ConsistentRead is invalid. The ConsistentRead flag should be either trueor false</error:INVALIDPARAMETERVALUE>
      <error:INVALIDQUERYEXPRESSION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidQueryExpression" http-error="400 Bad Request">The specified query expression syntax is not valid.</error:INVALIDQUERYEXPRESSION>
      <error:INVALIDRESPONSEGROUPS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidResponseGroups" http-error="400 Bad Request">The following response groups are invalid: " + invalidRGStr.</error:INVALIDRESPONSEGROUPS>
      <error:INVALIDSERVICE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidService" http-error="400 Bad Request">The Web Service " + serviceName + " does not exist.</error:INVALIDSERVICE>
      <error:INVALIDSOAPREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidSOAPRequest" http-error="400 Bad Request">Invalid SOAP request. " + reason".</error:INVALIDSOAPREQUEST>
      <error:INVALIDSORTEXPRESSION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidSortExpression" http-error="400 Bad Request">The sort attribute must be present in at least one of the predicates, and the predicate cannot contain the is null operator.</error:INVALIDSORTEXPRESSION>
      <error:INVALIDURI locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidURI" http-error="400 Bad Request">The URI " + requestURI + " is not valid.</error:INVALIDURI>
      <error:INVALIDWSADDRESSINGPROPERTY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidWSAddressingProperty" http-error="400 Bad Request">WS-Addressing parameter " + paramName + " has a wrong value: " + paramValue".</error:INVALIDWSADDRESSINGPROPERTY>
      <error:INVALIDWSDLVERSION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidWSDLVersion" http-error="400 Bad Request">Parameter (" + parameterName +") is only supported in WSDL version 2009-04-15 or beyond. Please upgrade to new version</error:INVALIDWSDLVERSION>
      <error:MALFORMEDSOAPSIGNATURE locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="MalformedSOAPSignature" http-error="403 Forbidden">Invalid SOAP Signature. " + reason".</error:MALFORMEDSOAPSIGNATURE>
      <error:MISSINGACTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingAction" http-error="400 Bad Request">No action was supplied with this request.</error:MISSINGACTION>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">The request must contain the specified missing parameter.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">The request must contain the parameter " + paramName".</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">The request must contain the parameter ItemName.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">The request must contain the parameter DomainName.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">Attribute.Value missing for Attribute.Name='name'.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">Attribute.Name missing for Attribute.Value='value'.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">No attributes for item ='" + itemName + "'.</error:MISSINGPARAMETER>
      <error:MISSINGPARAMETER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingParameter" http-error="400 Bad Request">The request must contain the parameter Name</error:MISSINGPARAMETER>
      <error:MISSINGWSADDRESSINGPROPERTY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingWSAddressingProperty" http-error="400 Bad Request">WS-Addressing is missing a required parameter (" + paramName + ")".</error:MISSINGWSADDRESSINGPROPERTY>
      <error:MULTIPLEEXISTSCONDITIONS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MultipleExistsConditions" http-error="400 Bad Request">Only one Exists condition can be specified</error:MULTIPLEEXISTSCONDITIONS>
      <error:MULTIPLEEXPECTEDNAMES locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MultipleExpectedNames" http-error="400 Bad Request">Only one Expected.Name can be specified</error:MULTIPLEEXPECTEDNAMES>
      <error:MULTIPLEEXPECTEDVALUES locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MultipleExpectedValues" http-error="400 Bad Request">Only one Expected.Value can be specified</error:MULTIPLEEXPECTEDVALUES>
      <error:MULTIVALUEDATTRIBUTE locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="MultiValuedAttribute" http-error="409 Conflict">Attribute (" + name + ") is multi-valued. Conditional check can only be performed on a single-valued attribute</error:MULTIVALUEDATTRIBUTE>
      <error:NOSUCHDOMAIN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="NoSuchDomain" http-error="400 Bad Request">The specified domain does not exist.</error:NOSUCHDOMAIN>
      <error:NOSUCHVERSION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="NoSuchVersion" http-error="400 Bad Request">The requested version (" + version + ") of service " + service + " does not exist.</error:NOSUCHVERSION>
      <error:NOTYETIMPLEMENTED locale="{$common_error:LOCALE_EN}" param="0" http-code="401" code="NotYetImplemented" http-error="401 Unauthorized">Feature " + feature + " is not yet available".</error:NOTYETIMPLEMENTED>
      <error:NUMBERDOMAINSEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberDomainsExceeded" http-error="409 Conflict">The domain limit was exceeded.</error:NUMBERDOMAINSEXCEEDED>
      <error:NUMBERDOMAINATTRIBUTESEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberDomainAttributesExceeded" http-error="409 Conflict">Too many attributes in this domain.</error:NUMBERDOMAINATTRIBUTESEXCEEDED>
      <error:NUMBERDOMAINBYTESEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberDomainBytesExceeded" http-error="409 Conflict">Too many bytes in this domain.</error:NUMBERDOMAINBYTESEXCEEDED>
      <error:NUMBERITEMATTRIBUTESEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberItemAttributesExceeded" http-error="409 Conflict">Too many attributes in this item.</error:NUMBERITEMATTRIBUTESEXCEEDED>
      <error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberSubmittedAttributesExceeded" http-error="409 Conflict">Too many attributes in a single call.</error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED>
      <error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberSubmittedAttributesExceeded" http-error="409 Conflict">Too many attributes for item itemName in a single call. Up to 256 attributes per call allowed.</error:NUMBERSUBMITTEDATTRIBUTESEXCEEDED>
      <error:NUMBERSUBMITTEDITEMSEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="NumberSubmittedItemsExceeded" http-error="409 Conflict">Too many items in a single call. Up to 25 items per call allowed.</error:NUMBERSUBMITTEDITEMSEXCEEDED>
      <error:REQUESTEXPIRED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestExpired" http-error="400 Bad Request">Request has expired. " + paramType + " date is " + date".</error:REQUESTEXPIRED>
      <error:REQUESTTIMEOUT locale="{$common_error:LOCALE_EN}" param="0" http-code="408" code="RequestTimeout" http-error="408 Request Timeout">A timeout occurred when attempting to query domain &lt;domain name&gt; with query expression &lt;query expression&gt;. BoxUsage [&lt;box usage value&gt;]".</error:REQUESTTIMEOUT>
      <error:SERVICEUNAVAILABLE locale="{$common_error:LOCALE_EN}" param="0" http-code="503" code="ServiceUnavailable" http-error="503 Service Unavailable">Service Amazon SimpleDB is currently unavailable. Please try again later.</error:SERVICEUNAVAILABLE>
      <error:TOOMANYREQUESTEDATTRIBUTES locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="TooManyRequestedAttributes" http-error="400 Bad Request">Too many attributes requested.</error:TOOMANYREQUESTEDATTRIBUTES>
      <error:UNSUPPORTEDHTTPVERB locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnsupportedHttpVerb" http-error="400 Bad Request">The requested HTTP verb is not supported: " + verb".</error:UNSUPPORTEDHTTPVERB>
      <error:UNSUPPORTEDNEXTTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnsupportedNextToken" http-error="400 Bad Request">The specified next token is no longer supported. Please resubmit your query.</error:UNSUPPORTEDNEXTTOKEN>
      <error:URITOOLONG locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="URITooLong" http-error="400 Bad Request">The URI exceeded the maximum limit of "+ maxLength".</error:URITOOLONG>
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


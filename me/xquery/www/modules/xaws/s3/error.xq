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
 :      Implementation of Error Messages returned from S3. 
 :
 :      http://docs.amazonwebservices.com/AmazonS3/2006-03-01/API/index.html?ErrorResponses.html
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 :)
module namespace error = 'http://www.xquery.me/modules/xaws/s3/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace common_error = 'http://www.xquery.me/modules/xaws/helpers/error';

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $error:ACCESSDENIED as xs:QName := xs:QName("error:ACCESSDENIED");
declare variable $error:ACCOUNTPROBLEM as xs:QName := xs:QName("error:ACCOUNTPROBLEM");
declare variable $error:AMBIGUOUSGRANTBYEMAILADDRESS as xs:QName := xs:QName("error:AMBIGUOUSGRANTBYEMAILADDRESS");
declare variable $error:BADDIGEST as xs:QName := xs:QName("error:BADDIGEST");
declare variable $error:BUCKETALREADYEXISTS as xs:QName := xs:QName("error:BUCKETALREADYEXISTS");
declare variable $error:BUCKETALREADYOWNEDBYYOU as xs:QName := xs:QName("error:BUCKETALREADYOWNEDBYYOU");
declare variable $error:BUCKETNOTEMPTY as xs:QName := xs:QName("error:BUCKETNOTEMPTY");
declare variable $error:CREDENTIALSNOTSUPPORTED as xs:QName := xs:QName("error:CREDENTIALSNOTSUPPORTED");
declare variable $error:CROSSLOCATIONLOGGINGPROHIBITED as xs:QName := xs:QName("error:CROSSLOCATIONLOGGINGPROHIBITED");
declare variable $error:ENTITYTOOSMALL as xs:QName := xs:QName("error:ENTITYTOOSMALL");
declare variable $error:ENTITYTOOLARGE as xs:QName := xs:QName("error:ENTITYTOOLARGE");
declare variable $error:EXPIREDTOKEN as xs:QName := xs:QName("error:EXPIREDTOKEN");
declare variable $error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION as xs:QName := xs:QName("error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION");
declare variable $error:INCOMPLETEBODY as xs:QName := xs:QName("error:INCOMPLETEBODY");
declare variable $error:INCORRECTNUMBEROFFILESINPOSTREQUEST as xs:QName := xs:QName("error:INCORRECTNUMBEROFFILESINPOSTREQUEST");
declare variable $error:INLINEDATATOOLARGE as xs:QName := xs:QName("error:INLINEDATATOOLARGE");
declare variable $error:INTERNALERROR as xs:QName := xs:QName("error:INTERNALERROR");
declare variable $error:INVALIDACCESSKEYID as xs:QName := xs:QName("error:INVALIDACCESSKEYID");
declare variable $error:INVALIDADDRESSINGHEADER as xs:QName := xs:QName("error:INVALIDADDRESSINGHEADER");
declare variable $error:INVALIDARGUMENT as xs:QName := xs:QName("error:INVALIDARGUMENT");
declare variable $error:INVALIDBUCKETNAME as xs:QName := xs:QName("error:INVALIDBUCKETNAME");
declare variable $error:INVALIDDIGEST as xs:QName := xs:QName("error:INVALIDDIGEST");
declare variable $error:INVALIDLOCATIONCONSTRAINT as xs:QName := xs:QName("error:INVALIDLOCATIONCONSTRAINT");
declare variable $error:INVALIDPAYER as xs:QName := xs:QName("error:INVALIDPAYER");
declare variable $error:INVALIDPOLICYDOCUMENT as xs:QName := xs:QName("error:INVALIDPOLICYDOCUMENT");
declare variable $error:INVALIDRANGE as xs:QName := xs:QName("error:INVALIDRANGE");
declare variable $error:INVALIDSECURITY as xs:QName := xs:QName("error:INVALIDSECURITY");
declare variable $error:INVALIDSOAPREQUEST as xs:QName := xs:QName("error:INVALIDSOAPREQUEST");
declare variable $error:INVALIDSTORAGECLASS as xs:QName := xs:QName("error:INVALIDSTORAGECLASS");
declare variable $error:INVALIDTARGETBUCKETFORLOGGING as xs:QName := xs:QName("error:INVALIDTARGETBUCKETFORLOGGING");
declare variable $error:INVALIDTOKEN as xs:QName := xs:QName("error:INVALIDTOKEN");
declare variable $error:INVALIDURI as xs:QName := xs:QName("error:INVALIDURI");
declare variable $error:KEYTOOLONG as xs:QName := xs:QName("error:KEYTOOLONG");
declare variable $error:MALFORMEDACLERROR as xs:QName := xs:QName("error:MALFORMEDACLERROR");
declare variable $error:MALFORMEDPOSTREQUEST as xs:QName := xs:QName("error:MALFORMEDPOSTREQUEST");
declare variable $error:MALFORMEDXML as xs:QName := xs:QName("error:MALFORMEDXML");
declare variable $error:MAXMESSAGELENGTHEXCEEDED as xs:QName := xs:QName("error:MAXMESSAGELENGTHEXCEEDED");
declare variable $error:MAXPOSTPREDATALENGTHEXCEEDEDERROR as xs:QName := xs:QName("error:MAXPOSTPREDATALENGTHEXCEEDEDERROR");
declare variable $error:METADATATOOLARGE as xs:QName := xs:QName("error:METADATATOOLARGE");
declare variable $error:METHODNOTALLOWED as xs:QName := xs:QName("error:METHODNOTALLOWED");
declare variable $error:MISSINGATTACHMENT as xs:QName := xs:QName("error:MISSINGATTACHMENT");
declare variable $error:MISSINGCONTENTLENGTH as xs:QName := xs:QName("error:MISSINGCONTENTLENGTH");
declare variable $error:MISSINGREQUESTBODYERROR as xs:QName := xs:QName("error:MISSINGREQUESTBODYERROR");
declare variable $error:MISSINGSECURITYELEMENT as xs:QName := xs:QName("error:MISSINGSECURITYELEMENT");
declare variable $error:MISSINGSECURITYHEADER as xs:QName := xs:QName("error:MISSINGSECURITYHEADER");
declare variable $error:NOLOGGINGSTATUSFORKEY as xs:QName := xs:QName("error:NOLOGGINGSTATUSFORKEY");
declare variable $error:NOSUCHBUCKET as xs:QName := xs:QName("error:NOSUCHBUCKET");
declare variable $error:NOSUCHKEY as xs:QName := xs:QName("error:NOSUCHKEY");
declare variable $error:NOSUCHVERSION as xs:QName := xs:QName("error:NOSUCHVERSION");
declare variable $error:NOTIMPLEMENTED as xs:QName := xs:QName("error:NOTIMPLEMENTED");
declare variable $error:NOTSIGNEDUP as xs:QName := xs:QName("error:NOTSIGNEDUP");
declare variable $error:OPERATIONABORTED as xs:QName := xs:QName("error:OPERATIONABORTED");
declare variable $error:PERMANENTREDIRECT as xs:QName := xs:QName("error:PERMANENTREDIRECT");
declare variable $error:PRECONDITIONFAILED as xs:QName := xs:QName("error:PRECONDITIONFAILED");
declare variable $error:REDIRECT as xs:QName := xs:QName("error:REDIRECT");
declare variable $error:REQUESTISNOTMULTIPARTCONTENT as xs:QName := xs:QName("error:REQUESTISNOTMULTIPARTCONTENT");
declare variable $error:REQUESTTIMEOUT as xs:QName := xs:QName("error:REQUESTTIMEOUT");
declare variable $error:REQUESTTIMETOOSKEWED as xs:QName := xs:QName("error:REQUESTTIMETOOSKEWED");
declare variable $error:REQUESTTORRENTOFBUCKETERROR as xs:QName := xs:QName("error:REQUESTTORRENTOFBUCKETERROR");
declare variable $error:SIGNATUREDOESNOTMATCH as xs:QName := xs:QName("error:SIGNATUREDOESNOTMATCH");
declare variable $error:SLOWDOWN as xs:QName := xs:QName("error:SLOWDOWN");
declare variable $error:TEMPORARYREDIRECT as xs:QName := xs:QName("error:TEMPORARYREDIRECT");
declare variable $error:TOKENREFRESHREQUIRED as xs:QName := xs:QName("error:TOKENREFRESHREQUIRED");
declare variable $error:TOOMANYBUCKETS as xs:QName := xs:QName("error:TOOMANYBUCKETS");
declare variable $error:UNEXPECTEDCONTENT as xs:QName := xs:QName("error:UNEXPECTEDCONTENT");
declare variable $error:UNRESOLVABLEGRANTBYEMAILADDRESS as xs:QName := xs:QName("error:UNRESOLVABLEGRANTBYEMAILADDRESS");
declare variable $error:USERKEYMUSTBESPECIFIED as xs:QName := xs:QName("error:USERKEYMUSTBESPECIFIED");

(: Error messages :)
declare variable $error:messages :=
    <error:messages>
      <error:ACCESSDENIED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AccessDenied" http-error="403 Forbidden">Access Denied</error:ACCESSDENIED>
      <error:ACCOUNTPROBLEM locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AccountProblem" http-error="403 Forbidden">There is a problem with your AWS account that prevents the operation from completing successfully. Please use Contact Us .</error:ACCOUNTPROBLEM>
      <error:AMBIGUOUSGRANTBYEMAILADDRESS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="AmbiguousGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided is associated with more than one account.</error:AMBIGUOUSGRANTBYEMAILADDRESS>
      <error:BADDIGEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="BadDigest" http-error="400 Bad Request">The Content-MD5 you specified did not match what we received.</error:BADDIGEST>
      <error:BUCKETALREADYEXISTS locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyExists" http-error="409 Conflict">The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.</error:BUCKETALREADYEXISTS>
      <error:BUCKETALREADYOWNEDBYYOU locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyOwnedByYou" http-error="409 Conflict">Your previous request to create the named bucket succeeded and you already own it.</error:BUCKETALREADYOWNEDBYYOU>
      <error:BUCKETNOTEMPTY locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketNotEmpty" http-error="409 Conflict">The bucket you tried to delete is not empty.</error:BUCKETNOTEMPTY>
      <error:CREDENTIALSNOTSUPPORTED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="CredentialsNotSupported" http-error="400 Bad Request">This request does not support credentials.</error:CREDENTIALSNOTSUPPORTED>
      <error:CROSSLOCATIONLOGGINGPROHIBITED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="CrossLocationLoggingProhibited" http-error="403 Forbidden">Cross location logging not allowed. Buckets in one geographic location cannot log information to a bucket in another location.</error:CROSSLOCATIONLOGGINGPROHIBITED>
      <error:ENTITYTOOSMALL locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="EntityTooSmall" http-error="400 Bad Request">Your proposed upload is smaller than the minimum allowed object size.</error:ENTITYTOOSMALL>
      <error:ENTITYTOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="EntityTooLarge" http-error="400 Bad Request">Your proposed upload exceeds the maximum allowed object size.</error:ENTITYTOOLARGE>
      <error:EXPIREDTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="ExpiredToken" http-error="400 Bad Request">The provided token has expired.</error:EXPIREDTOKEN>
      <error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IllegalVersioningConfigurationException" http-error="400 Bad Request">Indicates that the Versioning configuration specified in the request is invalid.</error:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION>
      <error:INCOMPLETEBODY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncompleteBody" http-error="400 Bad Request">You did not provide the number of bytes specified by the Content-Length HTTP header</error:INCOMPLETEBODY>
      <error:INCORRECTNUMBEROFFILESINPOSTREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncorrectNumberOfFilesInPostRequest" http-error="400 Bad Request">POST requires exactly one file upload per request.</error:INCORRECTNUMBEROFFILESINPOSTREQUEST>
      <error:INLINEDATATOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InlineDataTooLarge" http-error="400 Bad Request">Inline data exceeds the maximum allowed size.</error:INLINEDATATOOLARGE>
      <error:INTERNALERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="500" code="InternalError" http-error="500 Internal Server Error">We encountered an internal error. Please try again.</error:INTERNALERROR>
      <error:INVALIDACCESSKEYID locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidAccessKeyId" http-error="403 Forbidden">The AWS Access Key Id you provided does not exist in our records.</error:INVALIDACCESSKEYID>
      <error:INVALIDADDRESSINGHEADER locale="{$common_error:LOCALE_EN}" param="0" http-code="" code="InvalidAddressingHeader" http-error="">You must specify the Anonymous role.</error:INVALIDADDRESSINGHEADER>
      <error:INVALIDARGUMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidArgument" http-error="400 Bad Request">Invalid Argument</error:INVALIDARGUMENT>
      <error:INVALIDBUCKETNAME locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidBucketName" http-error="400 Bad Request">The specified bucket is not valid.</error:INVALIDBUCKETNAME>
      <error:INVALIDDIGEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidDigest" http-error="400 Bad Request">The Content-MD5 you specified was an invalid.</error:INVALIDDIGEST>
      <error:INVALIDLOCATIONCONSTRAINT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidLocationConstraint" http-error="400 Bad Request">The specified location constraint is not valid. For more information about Regions, see How to Select a Region for Your Buckets .</error:INVALIDLOCATIONCONSTRAINT>
      <error:INVALIDPAYER locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidPayer" http-error="403 Forbidden">All access to this object has been disabled.</error:INVALIDPAYER>
      <error:INVALIDPOLICYDOCUMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidPolicyDocument" http-error="400 Bad Request">The content of the form does not meet the conditions specified in the policy document.</error:INVALIDPOLICYDOCUMENT>
      <error:INVALIDRANGE locale="{$common_error:LOCALE_EN}" param="0" http-code="416" code="InvalidRange" http-error="416 Requested Range Not Satisfiable">The requested range cannot be satisfied.</error:INVALIDRANGE>
      <error:INVALIDSECURITY locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidSecurity" http-error="403 Forbidden">The provided security credentials are not valid.</error:INVALIDSECURITY>
      <error:INVALIDSOAPREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidSOAPRequest" http-error="400 Bad Request">The SOAP request body is invalid.</error:INVALIDSOAPREQUEST>
      <error:INVALIDSTORAGECLASS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidStorageClass" http-error="400 Bad Request">The storage class you specified is not valid.</error:INVALIDSTORAGECLASS>
      <error:INVALIDTARGETBUCKETFORLOGGING locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidTargetBucketForLogging" http-error="400 Bad Request">The target bucket for logging does not exist, is not owned by you, or does not have the appropriate grants for the log-delivery group.</error:INVALIDTARGETBUCKETFORLOGGING>
      <error:INVALIDTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidToken" http-error="400 Bad Request">The provided token is malformed or otherwise invalid.</error:INVALIDTOKEN>
      <error:INVALIDURI locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidURI" http-error="400 Bad Request">Couldn't parse the specified URI.</error:INVALIDURI>
      <error:KEYTOOLONG locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="KeyTooLong" http-error="400 Bad Request">Your key is too long.</error:KEYTOOLONG>
      <error:MALFORMEDACLERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</error:MALFORMEDACLERROR>
      <error:MALFORMEDACLERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</error:MALFORMEDACLERROR>
      <error:MALFORMEDPOSTREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedPOSTRequest" http-error="400 Bad Request">The body of your POST request is not well-formed multipart/form-data.</error:MALFORMEDPOSTREQUEST>
      <error:MALFORMEDXML locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedXML" http-error="400 Bad Request">This happens when the user sends a malformed xml (xml that doesn't conform to the published xsd) for the configuration. The error message is, "The XML you provided was not well-formed or did not validate against our published schema."</error:MALFORMEDXML>
      <error:MAXMESSAGELENGTHEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MaxMessageLengthExceeded" http-error="400 Bad Request">Your request was too big.</error:MAXMESSAGELENGTHEXCEEDED>
      <error:MAXPOSTPREDATALENGTHEXCEEDEDERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MaxPostPreDataLengthExceededError" http-error="400 Bad Request">Your POST request fields preceding the upload file were too large.</error:MAXPOSTPREDATALENGTHEXCEEDEDERROR>
      <error:METADATATOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MetadataTooLarge" http-error="400 Bad Request">Your metadata headers exceed the maximum allowed metadata size.</error:METADATATOOLARGE>
      <error:METHODNOTALLOWED locale="{$common_error:LOCALE_EN}" param="0" http-code="405" code="MethodNotAllowed" http-error="405 Method Not Allowed">The specified method is not allowed against this resource.</error:METHODNOTALLOWED>
      <error:MISSINGATTACHMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="" code="MissingAttachment" http-error="">A SOAP attachment was expected, but none were found.</error:MISSINGATTACHMENT>
      <error:MISSINGCONTENTLENGTH locale="{$common_error:LOCALE_EN}" param="0" http-code="411" code="MissingContentLength" http-error="411 Length Required">You must provide the Content-Length HTTP header.</error:MISSINGCONTENTLENGTH>
      <error:MISSINGREQUESTBODYERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingRequestBodyError" http-error="400 Bad Request">This happens when the user sends an empty xml document as a request. The error message is, "Request body is empty."</error:MISSINGREQUESTBODYERROR>
      <error:MISSINGSECURITYELEMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityElement" http-error="400 Bad Request">The SOAP 1.1 request is missing a security element.</error:MISSINGSECURITYELEMENT>
      <error:MISSINGSECURITYHEADER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityHeader" http-error="400 Bad Request">Your request was missing a required header.</error:MISSINGSECURITYHEADER>
      <error:NOLOGGINGSTATUSFORKEY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="NoLoggingStatusForKey" http-error="400 Bad Request">There is no such thing as a logging status sub-resource for a key.</error:NOLOGGINGSTATUSFORKEY>
      <error:NOSUCHBUCKET locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchBucket" http-error="404 Not Found">The specified bucket does not exist.</error:NOSUCHBUCKET>
      <error:NOSUCHKEY locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchKey" http-error="404 Not Found">The specified key does not exist.</error:NOSUCHKEY>
      <error:NOSUCHVERSION locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchVersion" http-error="404 Not Found">Indicates that the version ID specified in the request does not match an existing version.</error:NOSUCHVERSION>
      <error:NOTIMPLEMENTED locale="{$common_error:LOCALE_EN}" param="0" http-code="501" code="NotImplemented" http-error="501 Not Implemented">A header you provided implies functionality that is not implemented.</error:NOTIMPLEMENTED>
      <error:NOTSIGNEDUP locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="NotSignedUp" http-error="403 Forbidden">Your account is not signed up for the Amazon S3 service. You must sign up before you can use Amazon S3 . You can sign up at the following URL: http://aws.amazon.com/s3</error:NOTSIGNEDUP>
      <error:OPERATIONABORTED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="OperationAborted" http-error="409 Conflict">A conflicting conditional operation is currently in progress against this resource. Please try again.</error:OPERATIONABORTED>
      <error:PERMANENTREDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="301" code="PermanentRedirect" http-error="301 Moved Permanently">The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.</error:PERMANENTREDIRECT>
      <error:PRECONDITIONFAILED locale="{$common_error:LOCALE_EN}" param="0" http-code="412" code="PreconditionFailed" http-error="412 Precondition Failed">At least one of the pre-conditions you specified did not hold.</error:PRECONDITIONFAILED>
      <error:REDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="307" code="Redirect" http-error="307 Moved Temporarily">Temporary redirect.</error:REDIRECT>
      <error:REQUESTISNOTMULTIPARTCONTENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestIsNotMultiPartContent" http-error="400 Bad Request">Bucket POST must be of the enclosure-type multipart/form-data.</error:REQUESTISNOTMULTIPARTCONTENT>
      <error:REQUESTTIMEOUT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestTimeout" http-error="400 Bad Request">Your socket connection to the server was not read from or written to within the timeout period.</error:REQUESTTIMEOUT>
      <error:REQUESTTIMETOOSKEWED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="RequestTimeTooSkewed" http-error="403 Forbidden">The difference between the request time and the server's time is too large.</error:REQUESTTIMETOOSKEWED>
      <error:REQUESTTORRENTOFBUCKETERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestTorrentOfBucketError" http-error="400 Bad Request">Requesting the torrent file of a bucket is not permitted.</error:REQUESTTORRENTOFBUCKETERROR>
      <error:SIGNATUREDOESNOTMATCH locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="SignatureDoesNotMatch" http-error="403 Forbidden">The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method. For more information, see REST Authentication and SOAP Authentication for details.</error:SIGNATUREDOESNOTMATCH>
      <error:SLOWDOWN locale="{$common_error:LOCALE_EN}" param="0" http-code="503" code="SlowDown" http-error="503 Service Unavailable">Please reduce your request rate.</error:SLOWDOWN>
      <error:TEMPORARYREDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="307" code="TemporaryRedirect" http-error="307 Moved Temporarily">You are being redirected to the bucket while DNS updates.</error:TEMPORARYREDIRECT>
      <error:TOKENREFRESHREQUIRED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="TokenRefreshRequired" http-error="400 Bad Request">The provided token must be refreshed.</error:TOKENREFRESHREQUIRED>
      <error:TOOMANYBUCKETS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="TooManyBuckets" http-error="400 Bad Request">You have attempted to create more buckets than allowed.</error:TOOMANYBUCKETS>
      <error:UNEXPECTEDCONTENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnexpectedContent" http-error="400 Bad Request">This request does not support content.</error:UNEXPECTEDCONTENT>
      <error:UNRESOLVABLEGRANTBYEMAILADDRESS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnresolvableGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided does not match any account on record.</error:UNRESOLVABLEGRANTBYEMAILADDRESS>
      <error:USERKEYMUSTBESPECIFIED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UserKeyMustBeSpecified" http-error="400 Bad Request">The bucket POST must contain the specified field name. If it is specified, please check the order of the fields.</error:USERKEYMUSTBESPECIFIED>
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

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
module namespace s3_err = 'http://www.xquery.me/modules/xaws/s3/error';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace common_error = 'http://www.xquery.me/modules/xaws/helpers/error';

(: Error declarations for user convenience. Variables can be used to catch specific errors :)
declare variable $s3_err:ACCESSDENIED as xs:QName := xs:QName("s3_err:ACCESSDENIED");
declare variable $s3_err:ACCOUNTPROBLEM as xs:QName := xs:QName("s3_err:ACCOUNTPROBLEM");
declare variable $s3_err:AMBIGUOUSGRANTBYEMAILADDRESS as xs:QName := xs:QName("s3_err:AMBIGUOUSGRANTBYEMAILADDRESS");
declare variable $s3_err:BADDIGEST as xs:QName := xs:QName("s3_err:BADDIGEST");
declare variable $s3_err:BUCKETALREADYEXISTS as xs:QName := xs:QName("s3_err:BUCKETALREADYEXISTS");
declare variable $s3_err:BUCKETALREADYOWNEDBYYOU as xs:QName := xs:QName("s3_err:BUCKETALREADYOWNEDBYYOU");
declare variable $s3_err:BUCKETNOTEMPTY as xs:QName := xs:QName("s3_err:BUCKETNOTEMPTY");
declare variable $s3_err:CREDENTIALSNOTSUPPORTED as xs:QName := xs:QName("s3_err:CREDENTIALSNOTSUPPORTED");
declare variable $s3_err:CROSSLOCATIONLOGGINGPROHIBITED as xs:QName := xs:QName("s3_err:CROSSLOCATIONLOGGINGPROHIBITED");
declare variable $s3_err:ENTITYTOOSMALL as xs:QName := xs:QName("s3_err:ENTITYTOOSMALL");
declare variable $s3_err:ENTITYTOOLARGE as xs:QName := xs:QName("s3_err:ENTITYTOOLARGE");
declare variable $s3_err:EXPIREDTOKEN as xs:QName := xs:QName("s3_err:EXPIREDTOKEN");
declare variable $s3_err:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION as xs:QName := xs:QName("s3_err:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION");
declare variable $s3_err:INCOMPLETEBODY as xs:QName := xs:QName("s3_err:INCOMPLETEBODY");
declare variable $s3_err:INCORRECTNUMBEROFFILESINPOSTREQUEST as xs:QName := xs:QName("s3_err:INCORRECTNUMBEROFFILESINPOSTREQUEST");
declare variable $s3_err:INLINEDATATOOLARGE as xs:QName := xs:QName("s3_err:INLINEDATATOOLARGE");
declare variable $s3_err:INTERNALERROR as xs:QName := xs:QName("s3_err:INTERNALERROR");
declare variable $s3_err:INVALIDACCESSKEYID as xs:QName := xs:QName("s3_err:INVALIDACCESSKEYID");
declare variable $s3_err:INVALIDADDRESSINGHEADER as xs:QName := xs:QName("s3_err:INVALIDADDRESSINGHEADER");
declare variable $s3_err:INVALIDARGUMENT as xs:QName := xs:QName("s3_err:INVALIDARGUMENT");
declare variable $s3_err:INVALIDBUCKETNAME as xs:QName := xs:QName("s3_err:INVALIDBUCKETNAME");
declare variable $s3_err:INVALIDDIGEST as xs:QName := xs:QName("s3_err:INVALIDDIGEST");
declare variable $s3_err:INVALIDLOCATIONCONSTRAINT as xs:QName := xs:QName("s3_err:INVALIDLOCATIONCONSTRAINT");
declare variable $s3_err:INVALIDPAYER as xs:QName := xs:QName("s3_err:INVALIDPAYER");
declare variable $s3_err:INVALIDPOLICYDOCUMENT as xs:QName := xs:QName("s3_err:INVALIDPOLICYDOCUMENT");
declare variable $s3_err:INVALIDRANGE as xs:QName := xs:QName("s3_err:INVALIDRANGE");
declare variable $s3_err:INVALIDSECURITY as xs:QName := xs:QName("s3_err:INVALIDSECURITY");
declare variable $s3_err:INVALIDSOAPREQUEST as xs:QName := xs:QName("s3_err:INVALIDSOAPREQUEST");
declare variable $s3_err:INVALIDSTORAGECLASS as xs:QName := xs:QName("s3_err:INVALIDSTORAGECLASS");
declare variable $s3_err:INVALIDTARGETBUCKETFORLOGGING as xs:QName := xs:QName("s3_err:INVALIDTARGETBUCKETFORLOGGING");
declare variable $s3_err:INVALIDTOKEN as xs:QName := xs:QName("s3_err:INVALIDTOKEN");
declare variable $s3_err:INVALIDURI as xs:QName := xs:QName("s3_err:INVALIDURI");
declare variable $s3_err:KEYTOOLONG as xs:QName := xs:QName("s3_err:KEYTOOLONG");
declare variable $s3_err:MALFORMEDACLERROR as xs:QName := xs:QName("s3_err:MALFORMEDACLERROR");
declare variable $s3_err:MALFORMEDPOSTREQUEST as xs:QName := xs:QName("s3_err:MALFORMEDPOSTREQUEST");
declare variable $s3_err:MALFORMEDXML as xs:QName := xs:QName("s3_err:MALFORMEDXML");
declare variable $s3_err:MAXMESSAGELENGTHEXCEEDED as xs:QName := xs:QName("s3_err:MAXMESSAGELENGTHEXCEEDED");
declare variable $s3_err:MAXPOSTPREDATALENGTHEXCEEDEDERROR as xs:QName := xs:QName("s3_err:MAXPOSTPREDATALENGTHEXCEEDEDERROR");
declare variable $s3_err:METADATATOOLARGE as xs:QName := xs:QName("s3_err:METADATATOOLARGE");
declare variable $s3_err:METHODNOTALLOWED as xs:QName := xs:QName("s3_err:METHODNOTALLOWED");
declare variable $s3_err:MISSINGATTACHMENT as xs:QName := xs:QName("s3_err:MISSINGATTACHMENT");
declare variable $s3_err:MISSINGCONTENTLENGTH as xs:QName := xs:QName("s3_err:MISSINGCONTENTLENGTH");
declare variable $s3_err:MISSINGREQUESTBODYERROR as xs:QName := xs:QName("s3_err:MISSINGREQUESTBODYERROR");
declare variable $s3_err:MISSINGSECURITYELEMENT as xs:QName := xs:QName("s3_err:MISSINGSECURITYELEMENT");
declare variable $s3_err:MISSINGSECURITYHEADER as xs:QName := xs:QName("s3_err:MISSINGSECURITYHEADER");
declare variable $s3_err:NOLOGGINGSTATUSFORKEY as xs:QName := xs:QName("s3_err:NOLOGGINGSTATUSFORKEY");
declare variable $s3_err:NOSUCHBUCKET as xs:QName := xs:QName("s3_err:NOSUCHBUCKET");
declare variable $s3_err:NOSUCHKEY as xs:QName := xs:QName("s3_err:NOSUCHKEY");
declare variable $s3_err:NOSUCHVERSION as xs:QName := xs:QName("s3_err:NOSUCHVERSION");
declare variable $s3_err:NOTIMPLEMENTED as xs:QName := xs:QName("s3_err:NOTIMPLEMENTED");
declare variable $s3_err:NOTSIGNEDUP as xs:QName := xs:QName("s3_err:NOTSIGNEDUP");
declare variable $s3_err:OPERATIONABORTED as xs:QName := xs:QName("s3_err:OPERATIONABORTED");
declare variable $s3_err:PERMANENTREDIRECT as xs:QName := xs:QName("s3_err:PERMANENTREDIRECT");
declare variable $s3_err:PRECONDITIONFAILED as xs:QName := xs:QName("s3_err:PRECONDITIONFAILED");
declare variable $s3_err:REDIRECT as xs:QName := xs:QName("s3_err:REDIRECT");
declare variable $s3_err:REQUESTISNOTMULTIPARTCONTENT as xs:QName := xs:QName("s3_err:REQUESTISNOTMULTIPARTCONTENT");
declare variable $s3_err:REQUESTTIMEOUT as xs:QName := xs:QName("s3_err:REQUESTTIMEOUT");
declare variable $s3_err:REQUESTTIMETOOSKEWED as xs:QName := xs:QName("s3_err:REQUESTTIMETOOSKEWED");
declare variable $s3_err:REQUESTTORRENTOFBUCKETERROR as xs:QName := xs:QName("s3_err:REQUESTTORRENTOFBUCKETERROR");
declare variable $s3_err:SIGNATUREDOESNOTMATCH as xs:QName := xs:QName("s3_err:SIGNATUREDOESNOTMATCH");
declare variable $s3_err:SLOWDOWN as xs:QName := xs:QName("s3_err:SLOWDOWN");
declare variable $s3_err:TEMPORARYREDIRECT as xs:QName := xs:QName("s3_err:TEMPORARYREDIRECT");
declare variable $s3_err:TOKENREFRESHREQUIRED as xs:QName := xs:QName("s3_err:TOKENREFRESHREQUIRED");
declare variable $s3_err:TOOMANYBUCKETS as xs:QName := xs:QName("s3_err:TOOMANYBUCKETS");
declare variable $s3_err:UNEXPECTEDCONTENT as xs:QName := xs:QName("s3_err:UNEXPECTEDCONTENT");
declare variable $s3_err:UNRESOLVABLEGRANTBYEMAILADDRESS as xs:QName := xs:QName("s3_err:UNRESOLVABLEGRANTBYEMAILADDRESS");
declare variable $s3_err:USERKEYMUSTBESPECIFIED as xs:QName := xs:QName("s3_err:USERKEYMUSTBESPECIFIED");

(: Error messages :)
declare variable $s3_err:messages :=
    <s3_err:messages>
      <s3_err:ACCESSDENIED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AccessDenied" http-error="403 Forbidden">Access Denied</s3_err:ACCESSDENIED>
      <s3_err:ACCOUNTPROBLEM locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="AccountProblem" http-error="403 Forbidden">There is a problem with your AWS account that prevents the operation from completing successfully. Please use Contact Us .</s3_err:ACCOUNTPROBLEM>
      <s3_err:AMBIGUOUSGRANTBYEMAILADDRESS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="AmbiguousGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided is associated with more than one account.</s3_err:AMBIGUOUSGRANTBYEMAILADDRESS>
      <s3_err:BADDIGEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="BadDigest" http-error="400 Bad Request">The Content-MD5 you specified did not match what we received.</s3_err:BADDIGEST>
      <s3_err:BUCKETALREADYEXISTS locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyExists" http-error="409 Conflict">The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.</s3_err:BUCKETALREADYEXISTS>
      <s3_err:BUCKETALREADYOWNEDBYYOU locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketAlreadyOwnedByYou" http-error="409 Conflict">Your previous request to create the named bucket succeeded and you already own it.</s3_err:BUCKETALREADYOWNEDBYYOU>
      <s3_err:BUCKETNOTEMPTY locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="BucketNotEmpty" http-error="409 Conflict">The bucket you tried to delete is not empty.</s3_err:BUCKETNOTEMPTY>
      <s3_err:CREDENTIALSNOTSUPPORTED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="CredentialsNotSupported" http-error="400 Bad Request">This request does not support credentials.</s3_err:CREDENTIALSNOTSUPPORTED>
      <s3_err:CROSSLOCATIONLOGGINGPROHIBITED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="CrossLocationLoggingProhibited" http-error="403 Forbidden">Cross location logging not allowed. Buckets in one geographic location cannot log information to a bucket in another location.</s3_err:CROSSLOCATIONLOGGINGPROHIBITED>
      <s3_err:ENTITYTOOSMALL locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="EntityTooSmall" http-error="400 Bad Request">Your proposed upload is smaller than the minimum allowed object size.</s3_err:ENTITYTOOSMALL>
      <s3_err:ENTITYTOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="EntityTooLarge" http-error="400 Bad Request">Your proposed upload exceeds the maximum allowed object size.</s3_err:ENTITYTOOLARGE>
      <s3_err:EXPIREDTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="ExpiredToken" http-error="400 Bad Request">The provided token has expired.</s3_err:EXPIREDTOKEN>
      <s3_err:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IllegalVersioningConfigurationException" http-error="400 Bad Request">Indicates that the Versioning configuration specified in the request is invalid.</s3_err:ILLEGALVERSIONINGCONFIGURATIONEXCEPTION>
      <s3_err:INCOMPLETEBODY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncompleteBody" http-error="400 Bad Request">You did not provide the number of bytes specified by the Content-Length HTTP header</s3_err:INCOMPLETEBODY>
      <s3_err:INCORRECTNUMBEROFFILESINPOSTREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="IncorrectNumberOfFilesInPostRequest" http-error="400 Bad Request">POST requires exactly one file upload per request.</s3_err:INCORRECTNUMBEROFFILESINPOSTREQUEST>
      <s3_err:INLINEDATATOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InlineDataTooLarge" http-error="400 Bad Request">Inline data exceeds the maximum allowed size.</s3_err:INLINEDATATOOLARGE>
      <s3_err:INTERNALERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="500" code="InternalError" http-error="500 Internal Server Error">We encountered an internal error. Please try again.</s3_err:INTERNALERROR>
      <s3_err:INVALIDACCESSKEYID locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidAccessKeyId" http-error="403 Forbidden">The AWS Access Key Id you provided does not exist in our records.</s3_err:INVALIDACCESSKEYID>
      <s3_err:INVALIDADDRESSINGHEADER locale="{$common_error:LOCALE_EN}" param="0" http-code="" code="InvalidAddressingHeader" http-error="">You must specify the Anonymous role.</s3_err:INVALIDADDRESSINGHEADER>
      <s3_err:INVALIDARGUMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidArgument" http-error="400 Bad Request">Invalid Argument</s3_err:INVALIDARGUMENT>
      <s3_err:INVALIDBUCKETNAME locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidBucketName" http-error="400 Bad Request">The specified bucket is not valid.</s3_err:INVALIDBUCKETNAME>
      <s3_err:INVALIDDIGEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidDigest" http-error="400 Bad Request">The Content-MD5 you specified was an invalid.</s3_err:INVALIDDIGEST>
      <s3_err:INVALIDLOCATIONCONSTRAINT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidLocationConstraint" http-error="400 Bad Request">The specified location constraint is not valid. For more information about Regions, see How to Select a Region for Your Buckets .</s3_err:INVALIDLOCATIONCONSTRAINT>
      <s3_err:INVALIDPAYER locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidPayer" http-error="403 Forbidden">All access to this object has been disabled.</s3_err:INVALIDPAYER>
      <s3_err:INVALIDPOLICYDOCUMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidPolicyDocument" http-error="400 Bad Request">The content of the form does not meet the conditions specified in the policy document.</s3_err:INVALIDPOLICYDOCUMENT>
      <s3_err:INVALIDRANGE locale="{$common_error:LOCALE_EN}" param="0" http-code="416" code="InvalidRange" http-error="416 Requested Range Not Satisfiable">The requested range cannot be satisfied.</s3_err:INVALIDRANGE>
      <s3_err:INVALIDSECURITY locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="InvalidSecurity" http-error="403 Forbidden">The provided security credentials are not valid.</s3_err:INVALIDSECURITY>
      <s3_err:INVALIDSOAPREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidSOAPRequest" http-error="400 Bad Request">The SOAP request body is invalid.</s3_err:INVALIDSOAPREQUEST>
      <s3_err:INVALIDSTORAGECLASS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidStorageClass" http-error="400 Bad Request">The storage class you specified is not valid.</s3_err:INVALIDSTORAGECLASS>
      <s3_err:INVALIDTARGETBUCKETFORLOGGING locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidTargetBucketForLogging" http-error="400 Bad Request">The target bucket for logging does not exist, is not owned by you, or does not have the appropriate grants for the log-delivery group.</s3_err:INVALIDTARGETBUCKETFORLOGGING>
      <s3_err:INVALIDTOKEN locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidToken" http-error="400 Bad Request">The provided token is malformed or otherwise invalid.</s3_err:INVALIDTOKEN>
      <s3_err:INVALIDURI locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="InvalidURI" http-error="400 Bad Request">Couldn't parse the specified URI.</s3_err:INVALIDURI>
      <s3_err:KEYTOOLONG locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="KeyTooLong" http-error="400 Bad Request">Your key is too long.</s3_err:KEYTOOLONG>
      <s3_err:MALFORMEDACLERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</s3_err:MALFORMEDACLERROR>
      <s3_err:MALFORMEDACLERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedACLError" http-error="400 Bad Request">The XML you provided was not well-formed or did not validate against our published schema.</s3_err:MALFORMEDACLERROR>
      <s3_err:MALFORMEDPOSTREQUEST locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedPOSTRequest" http-error="400 Bad Request">The body of your POST request is not well-formed multipart/form-data.</s3_err:MALFORMEDPOSTREQUEST>
      <s3_err:MALFORMEDXML locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MalformedXML" http-error="400 Bad Request">This happens when the user sends a malformed xml (xml that doesn't conform to the published xsd) for the configuration. The error message is, "The XML you provided was not well-formed or did not validate against our published schema."</s3_err:MALFORMEDXML>
      <s3_err:MAXMESSAGELENGTHEXCEEDED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MaxMessageLengthExceeded" http-error="400 Bad Request">Your request was too big.</s3_err:MAXMESSAGELENGTHEXCEEDED>
      <s3_err:MAXPOSTPREDATALENGTHEXCEEDEDERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MaxPostPreDataLengthExceededError" http-error="400 Bad Request">Your POST request fields preceding the upload file were too large.</s3_err:MAXPOSTPREDATALENGTHEXCEEDEDERROR>
      <s3_err:METADATATOOLARGE locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MetadataTooLarge" http-error="400 Bad Request">Your metadata headers exceed the maximum allowed metadata size.</s3_err:METADATATOOLARGE>
      <s3_err:METHODNOTALLOWED locale="{$common_error:LOCALE_EN}" param="0" http-code="405" code="MethodNotAllowed" http-error="405 Method Not Allowed">The specified method is not allowed against this resource.</s3_err:METHODNOTALLOWED>
      <s3_err:MISSINGATTACHMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="" code="MissingAttachment" http-error="">A SOAP attachment was expected, but none were found.</s3_err:MISSINGATTACHMENT>
      <s3_err:MISSINGCONTENTLENGTH locale="{$common_error:LOCALE_EN}" param="0" http-code="411" code="MissingContentLength" http-error="411 Length Required">You must provide the Content-Length HTTP header.</s3_err:MISSINGCONTENTLENGTH>
      <s3_err:MISSINGREQUESTBODYERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingRequestBodyError" http-error="400 Bad Request">This happens when the user sends an empty xml document as a request. The error message is, "Request body is empty."</s3_err:MISSINGREQUESTBODYERROR>
      <s3_err:MISSINGSECURITYELEMENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityElement" http-error="400 Bad Request">The SOAP 1.1 request is missing a security element.</s3_err:MISSINGSECURITYELEMENT>
      <s3_err:MISSINGSECURITYHEADER locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="MissingSecurityHeader" http-error="400 Bad Request">Your request was missing a required header.</s3_err:MISSINGSECURITYHEADER>
      <s3_err:NOLOGGINGSTATUSFORKEY locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="NoLoggingStatusForKey" http-error="400 Bad Request">There is no such thing as a logging status sub-resource for a key.</s3_err:NOLOGGINGSTATUSFORKEY>
      <s3_err:NOSUCHBUCKET locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchBucket" http-error="404 Not Found">The specified bucket does not exist.</s3_err:NOSUCHBUCKET>
      <s3_err:NOSUCHKEY locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchKey" http-error="404 Not Found">The specified key does not exist.</s3_err:NOSUCHKEY>
      <s3_err:NOSUCHVERSION locale="{$common_error:LOCALE_EN}" param="0" http-code="404" code="NoSuchVersion" http-error="404 Not Found">Indicates that the version ID specified in the request does not match an existing version.</s3_err:NOSUCHVERSION>
      <s3_err:NOTIMPLEMENTED locale="{$common_error:LOCALE_EN}" param="0" http-code="501" code="NotImplemented" http-error="501 Not Implemented">A header you provided implies functionality that is not implemented.</s3_err:NOTIMPLEMENTED>
      <s3_err:NOTSIGNEDUP locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="NotSignedUp" http-error="403 Forbidden">Your account is not signed up for the Amazon S3 service. You must sign up before you can use Amazon S3 . You can sign up at the following URL: http://aws.amazon.com/s3</s3_err:NOTSIGNEDUP>
      <s3_err:OPERATIONABORTED locale="{$common_error:LOCALE_EN}" param="0" http-code="409" code="OperationAborted" http-error="409 Conflict">A conflicting conditional operation is currently in progress against this resource. Please try again.</s3_err:OPERATIONABORTED>
      <s3_err:PERMANENTREDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="301" code="PermanentRedirect" http-error="301 Moved Permanently">The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.</s3_err:PERMANENTREDIRECT>
      <s3_err:PRECONDITIONFAILED locale="{$common_error:LOCALE_EN}" param="0" http-code="412" code="PreconditionFailed" http-error="412 Precondition Failed">At least one of the pre-conditions you specified did not hold.</s3_err:PRECONDITIONFAILED>
      <s3_err:REDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="307" code="Redirect" http-error="307 Moved Temporarily">Temporary redirect.</s3_err:REDIRECT>
      <s3_err:REQUESTISNOTMULTIPARTCONTENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestIsNotMultiPartContent" http-error="400 Bad Request">Bucket POST must be of the enclosure-type multipart/form-data.</s3_err:REQUESTISNOTMULTIPARTCONTENT>
      <s3_err:REQUESTTIMEOUT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestTimeout" http-error="400 Bad Request">Your socket connection to the server was not read from or written to within the timeout period.</s3_err:REQUESTTIMEOUT>
      <s3_err:REQUESTTIMETOOSKEWED locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="RequestTimeTooSkewed" http-error="403 Forbidden">The difference between the request time and the server's time is too large.</s3_err:REQUESTTIMETOOSKEWED>
      <s3_err:REQUESTTORRENTOFBUCKETERROR locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="RequestTorrentOfBucketError" http-error="400 Bad Request">Requesting the torrent file of a bucket is not permitted.</s3_err:REQUESTTORRENTOFBUCKETERROR>
      <s3_err:SIGNATUREDOESNOTMATCH locale="{$common_error:LOCALE_EN}" param="0" http-code="403" code="SignatureDoesNotMatch" http-error="403 Forbidden">The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method. For more information, see REST Authentication and SOAP Authentication for details.</s3_err:SIGNATUREDOESNOTMATCH>
      <s3_err:SLOWDOWN locale="{$common_error:LOCALE_EN}" param="0" http-code="503" code="SlowDown" http-error="503 Service Unavailable">Please reduce your request rate.</s3_err:SLOWDOWN>
      <s3_err:TEMPORARYREDIRECT locale="{$common_error:LOCALE_EN}" param="0" http-code="307" code="TemporaryRedirect" http-error="307 Moved Temporarily">You are being redirected to the bucket while DNS updates.</s3_err:TEMPORARYREDIRECT>
      <s3_err:TOKENREFRESHREQUIRED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="TokenRefreshRequired" http-error="400 Bad Request">The provided token must be refreshed.</s3_err:TOKENREFRESHREQUIRED>
      <s3_err:TOOMANYBUCKETS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="TooManyBuckets" http-error="400 Bad Request">You have attempted to create more buckets than allowed.</s3_err:TOOMANYBUCKETS>
      <s3_err:UNEXPECTEDCONTENT locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnexpectedContent" http-error="400 Bad Request">This request does not support content.</s3_err:UNEXPECTEDCONTENT>
      <s3_err:UNRESOLVABLEGRANTBYEMAILADDRESS locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UnresolvableGrantByEmailAddress" http-error="400 Bad Request">The e-mail address you provided does not match any account on record.</s3_err:UNRESOLVABLEGRANTBYEMAILADDRESS>
      <s3_err:USERKEYMUSTBESPECIFIED locale="{$common_error:LOCALE_EN}" param="0" http-code="400" code="UserKeyMustBeSpecified" http-error="400 Bad Request">The bucket POST must contain the specified field name. If it is specified, please check the order of the fields.</s3_err:USERKEYMUSTBESPECIFIED>
    </s3_err:messages>;


(:~
 :  Throws an error with the default locale.
 : 
:)
declare function s3_err:throw(
                    $http_code as xs:double, 
                    $http_response as item()*) {

    common_error:throw($http_code,$http_response,"en_EN",$s3_err:messages)
};


declare function s3_err:throw(
                    $http_code as xs:double, 
                    $http_response as item()*,
                    $locale as xs:string) {

    common_error:throw($http_code, $http_response, $locale,$s3_err:messages)
};

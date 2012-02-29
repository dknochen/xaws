import module namespace system = "http://www.zorba-xquery.com/modules/system";
 
import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";  
import module namespace user = "http://www.xquery.me/modules/xaws/iam/user"; 
import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";
import module namespace sts = "http://www.xquery.me/modules/xaws/iam/sts";

declare namespace iam = "https://iam.amazonaws.com/doc/2010-05-08/";
declare namespace s = "https://sts.amazonaws.com/doc/2011-06-15/";
declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";

declare variable $AWS_ACCESS_KEY := system:property("env.AWS_ACCESS_KEY");
declare variable $AWS_SECRET := system:property("env.AWS_SECRET");
(: Uses an alternate user who is allowed to create federation tokens :)
declare variable $aws-config2 := config:create("AKIAJX32MV2T3WUZMLOA","fOeTlOk51bb5chNnhUdjJjNzTAhm7pBFpoB9tRzY");



let $policy := policy:create(
 <Policy>
   <Statement>
     <Effect>Allow</Effect>
     <Action>ec2:Describe*</Action>
     <Resource>*</Resource>
   </Statement>
 </Policy>)
let $result := sts:getFederationToken($aws-config2, "TempUser", $policy, 3600)/s:GetFederationTokenResponse/s:GetFederationTokenResult/s:Credentials
return not(fn:empty($result))
import module namespace system = "http://www.zorba-xquery.com/modules/system";
 
import module namespace config = "http://www.xquery.me/modules/xaws/helpers/config";  
import module namespace user = "http://www.xquery.me/modules/xaws/iam/user"; 
import module namespace policy = "http://www.xquery.me/modules/xaws/iam/policy";

declare namespace iam = "https://iam.amazonaws.com/doc/2010-05-08/";
declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";

declare variable $AWS_ACCESS_KEY := system:property("env.AWS_ACCESS_KEY");
declare variable $AWS_SECRET := system:property("env.AWS_SECRET");
declare variable $aws-config := config:create($AWS_ACCESS_KEY,$AWS_SECRET);

try { user:createUser($aws-config, "TestUser"); } catch * { (); }

let $policy := policy:create(
 <Policy>
   <Statement>
     <Effect>Allow</Effect>
     <Action>ec2:Describe*</Action>
     <Resource>*</Resource>
   </Statement>
 </Policy>
)
return policy:putUserPolicy($aws-config,"TestUser","DemoPolicy",$policy);

policy:getUserPolicy($aws-config,"TestUser","DemoPolicy")/iam:GetUserPolicyResponse/iam:GetUserPolicyResult

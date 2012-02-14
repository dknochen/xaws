import module namespace system = "http://www.zorba-xquery.com/modules/system";

import module namespace bucket = 'http://www.xquery.me/modules/xaws/s3/bucket';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error';
import module namespace config = "http://www.xquery.me/modules/xaws/s3/config";

import module namespace http = "http://expath.org/ns/http-client";

declare namespace aws = "http://s3.amazonaws.com/doc/2006-03-01/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace zerr = "http://www.zorba-xquery.com/errors";

declare variable $AWS_ACCESS_KEY := system:property("env.AWS_ACCESS_KEY");
declare variable $AWS_SECRET := system:property("env.AWS_SECRET");
declare variable $AWS_USER_ID := system:property("env.AWS_USER_ID");
declare variable $aws-config := config:create($AWS_ACCESS_KEY,$AWS_SECRET);

declare variable $bucket-name := concat("test.xquery.me.bucket.",$AWS_USER_ID);
declare variable $result := ();    
declare variable $success := false();
declare variable $msg := ();

declare %ann:sequential function local:checkExists($bucket as xs:string) as xs:boolean
{
  variable $result := bucket:list($aws-config);
  
  boolean(trace($result//aws:Bucket/aws:Name,"existing-buckets")[text() eq $bucket])
};

bucket:create($aws-config,<create-config><acl>public-read</acl></create-config>, $bucket-name);
        
{
  if(local:checkExists($bucket-name))
  then
    {
      bucket:delete($aws-config,$bucket-name);     
	  
      if(not(local:checkExists($bucket-name)))
      then
	    $success := true();
      else 
	    $msg := ("Bucket was not deleted",error:serialize($result));
    }
  else 
    $msg := ("Bucket was not created: ",error:serialize($result));
}

<test success="{$success}">{$msg}</test>
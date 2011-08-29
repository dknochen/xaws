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
module namespace const = 'http://www.xquery.me/modules/xaws/s3/constants';

declare variable $const:ACL-GRANT-PRIVATE := "private";
declare variable $const:ACL-GRANT-PUBLIC-READ := "public-read";
declare variable $const:ACL-GRANT-PUBLIC-READ-WRITE := "public-read-write";
declare variable $const:ACL-GRANT-AUTHENTICATED-READ := "authenticated-read";
declare variable $const:ACL-GRANT-BUCKET-OWNER-READ := "bucket-owner-read";
declare variable $const:ACL-GRANT-BUCKET-OWNER-FULL-CONTROL := "bucket-owner-full-control";

declare variable $const:ACS-GROUPS-GLOBAL-AUTHENTICATED-USERS := "http://acs.amazonaws.com/groups/global/AuthenticatedUsers";

declare variable $const:LOCATION-EU := "EU";

declare variable $const:PAYER_REQUESTER := "Requester";
declare variable $const:PAYER_BUCKET_OWNER := "BucketOwner";


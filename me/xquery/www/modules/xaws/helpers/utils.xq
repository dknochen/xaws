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
 :)
module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace date = "http://www.zorba-xquery.com/modules/datetime";

(:~
 : Generate a date formated according to rfc822. Example: Fri, 15 Oct 10
 :
 : cf: http://www.faqs.org/rfcs/rfc822.html
 :
 : @return rfc822 formated date as xs:string
:)
declare function utils:http-date() as xs:string {

    let $format as xs:string := "[FNn,3-3], [D01] [MNn,3-3] [Y01] [H01]:[m01]:[s01] PST" 
    return 
        format-dateTime(
            adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('-PT8H'))
            ,$format, "en", (), ()
        )
};

(:~
 : Generate a date formated: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
 :
 : @return rfc822 formated date as xs:string
:)
declare function utils:timestamp() as xs:string {

    let $format as xs:string := "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01].[f001]Z" 
    return 
        format-dateTime(
            adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('-PT0H'))
            ,$format, "en", (), ()
        )
};

declare sequential function utils:sleep($sec as xs:integer) {

    declare $duration as xs:dayTimeDuration := xs:dayTimeDuration(concat('PT',string($sec),'S'));
    declare $start-time := date:current-dateTime();
    declare $run-time as xs:dayTimeDuration := xs:dayTimeDuration('PT0S');
    
    while ($run-time < $duration) {
        set $run-time := 
            let $time := date:current-dateTime()
            return
                $time - $start-time;  
    }
};

declare updating function utils:insert-replace ($target-node as element(), $insert-replace as node()) {
    let $replace-node := $target-node/node[name() eq $insert-replace/name()]
    return
        if ( $replace-node )
        then
            replace node $replace-node with $insert-replace
        else
           insert node $insert-replace as last into $target-node
};


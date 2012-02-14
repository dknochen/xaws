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
 :      This Module provides functions to interact with the Amazon Simple DB
 :      (SDB) webservice.
 :
 :      Amazon Simple DB is a highly available, scalable, and flexible 
 :      non-relational data store that provides functions to simply store
 :      and query data items via web service requests.
 : </p>
 : 
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 : @author Dennis Knochenwefel dennis [at] xquery [dot] co [dot] uk
 :)
module namespace domain = 'http://www.xquery.me/modules/xaws/sdb/domain';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace sdb_request = 'http://www.xquery.me/modules/xaws/sdb/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/sdb/error';

declare namespace aws = "http://sdb.amazonaws.com/doc/2009-04-15/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The ListDomains operation lists all domains associated with the Access Key ID. 
 : It returns domain names up to the limit set by MaxNumberOfDomains. A NextToken is returned 
 : if there are more than MaxNumberOfDomains domains. Calling ListDomains successive times with 
 : the NextToken returns up to MaxNumberOfDomains more domain names each time."</blockquote>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListDomainsResponse element 
:)
declare %ann:sequential function domain:list(
    $aws-config as element(aws-config)
) as item()* {

    domain:list($aws-config,())
    
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The ListDomains operation lists all domains associated with the Access Key ID. 
 : It returns domain names up to the limit set by MaxNumberOfDomains. A NextToken is returned 
 : if there are more than MaxNumberOfDomains domains. Calling ListDomains successive times with 
 : the NextToken returns up to MaxNumberOfDomains more domain names each time."</blockquote>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $max-number-of-domains The maximum number of domain names you want returned (range: 1 - 100, default: 100)
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListDomainsResponse element 
:)
declare %ann:sequential function domain:list(
    $aws-config as element(aws-config),
    $list-config as element(list-config)?
) as item()* {

    let $href as xs:string := request:href($aws-config, "sdb.amazonaws.com/")
    let $parameters := (
            <parameter name="Action" value="ListDomains" /> ,
            utils:if-then($list-config,
              (
                utils:if-then($list-config/max-number-of-domains,
                              <parameter name="MaxNumberOfDomains" value="{$list-config/max-number-of-domains/text()}" />),
                utils:if-then($list-config/next-token,
                              <parameter name="NextToken" value="{$list-config/next-token/text()}" />)
              )
            )
        )
    let $request := request:create("GET",$href,$parameters)
    let $response := sdb_request:send($aws-config,$request,$parameters)
    return 
        $response
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The CreateDomain operation creates a new domain. The domain name must be unique 
 : among the domains associated with the Access Key ID provided in the request. The CreateDomain 
 : operation might take 10 or more seconds to complete."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>The domain name must be unique among the domains 
 :     associated with the Access Key ID provided in the 
 :     request.
 : </li>
 : <li>The CreateDomain operation might take 10 or more 
 :     seconds to complete.
 : </li>
 : <li>The CreateDomain operation is idempotent. That means, 
 :     trying to create a domain with an existing name multiple 
 :     times will not result in an error response
 : </li>
 : <li>You can create up to 100 domains per account.
 : </li>
 : </ul> 
 : 
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain you want to create. The name can range between 3 and 255 characters and can contain the following characters: a-z, A-Z, 0-9, '_', '-', and '.'
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:CreateDomainResponse element 
:)
declare %ann:sequential function domain:create(
    $aws-config as element(aws-config),
    $domain-name as xs:string
) as item()* {

    domain:action($aws-config,$domain-name,"CreateDomain")

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The DeleteDomain operation deletes a domain. Any items (and their attributes) 
 : in the domain are deleted as well. The DeleteDomain operation might take 10 or more seconds 
 : to complete."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>Running DeleteDomain on a domain that does not exist or running the function multiple 
 :     times using the same domain name will not result in an error response.
 : </li>
 : </ul> 
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain you want to delete.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:DeleteDomainResponse element
:)
declare %ann:sequential function domain:delete(
    $aws-config as element(aws-config),
    $domain-name as xs:string
) as item()* {
  
    domain:action($aws-config,$domain-name,"DeleteDomain")

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Returns information about the domain, including when the domain was created, 
 : the number of items and attributes, and the size of attribute names and values."</blockquote>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain you want information about.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:DomainMetadataResponse element
:)
declare %ann:sequential function domain:metadata(
    $aws-config as element(aws-config),
    $domain-name as xs:string
) as item()* {
  
    domain:action($aws-config,$domain-name,"DomainMetadata")
  
};



declare %private %ann:sequential function domain:action(
    $aws-config as element(aws-config),
    $domain-name as xs:string,
    $action as xs:string
) as item()* {
  
    let $href as xs:string := request:href($aws-config, "sdb.amazonaws.com/")
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="{$action}" /> 
    )
    let $request := request:create("GET",$href,$parameters)
    let $response := sdb_request:send($aws-config,$request,$parameters)
    return 
        $response

};
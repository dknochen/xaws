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
 :)
module namespace domain = 'http://www.xquery.me/modules/xaws/sdb/domain';

import module namespace http = "http://expath.org/ns/http-client";

import module namespace sdb_request = 'http://www.xquery.me/modules/xaws/sdb/request';
import module namespace request = 'http://www.xquery.me/modules/xaws/helpers/request';
import module namespace utils = 'http://www.xquery.me/modules/xaws/helpers/utils';
import module namespace error = 'http://www.xquery.me/modules/xaws/sdb/error';

declare namespace aws = "http://sdb.amazonaws.com/doc/2009-04-15/";
declare namespace ann = "http://www.zorba-xquery.com/annotations";

declare variable $domain:host as xs:string := "sdb.amazonaws.com";
declare variable $domain:path as xs:string := "/";
declare variable $domain:href as xs:string := concat("http://",$domain:host,$domain:path);
declare variable $domain:version as xs:string := "2009-04-15";

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
    $aws-access-key as xs:string, 
    $aws-secret as xs:string
) as item()* {

    domain:list($aws-access-key,$aws-secret,(),())
    
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
 : @param $next-token Token returned by the previous request. Can be passed along to the next request
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:ListDomainsResponse element 
:)
declare %ann:sequential function domain:list(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $next-token as xs:string
) as item()* {
    
    domain:list($aws-access-key,$aws-secret,(),$next-token)
    
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
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $max-number-of-domains as xs:string?,
    $next-token as xs:string?
) as item()* {

    let $parameters := (
            <parameter name="Action" value="ListDomains" /> ,
            if ($max-number-of-domains)
            then
                <parameter name="MaxNumberOfDomains" value="{$max-number-of-domains}" />  
            else
                (),
            if ($next-token)
            then
                <parameter name="NextToken" value="{$next-token}" />  
            else
                ()
        )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
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
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string
) as item()* {

    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="CreateDomain" /> 
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
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
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string
) as item()* {
  
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="DeleteDomain" /> 
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
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
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string
) as item()* {
  
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="DomainMetadata" /> 
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The PutAttributes operation creates or replaces attributes in an item. You 
 : specify new attributes using a combination of the Attribute.X.Name and Attribute.X.Value 
 : parameters. You specify the first attribute by the parameters Attribute.1.Name and 
 : Attribute.1.Value, the second attribute by the parameters Attribute.2.Name and 
 : Attribute.2.Value, and so on.
 :
 : Attributes are uniquely identified in an item by their name/value combination. For 
 : example, a single item can have the attributes { "first_name", "first_value" } and 
 : { "first_name", second_value" }. However, it cannot have two attribute instances where 
 : both the Attribute.X.Name and Attribute.X.Value are the same.
 :
 : Optionally, the requester can supply the Replace parameter for each individual attribute. 
 : Setting this value to true causes the new attribute value to replace the existing attribute 
 : value(s). For example, if an item has the attributes { 'a', '1' }, { 'b', '2'} and 
 : { 'b', '3' } and the requester calls PutAttributes using the attributes { 'b', '4' } with 
 : the Replace parameter set to true, the final attributes of the item are changed to 
 : { 'a', '1' } and { 'b', '4' }, which replaces the previous values of the 'b' attribute with 
 : the new value.
 : 
 : Conditional updates are useful for ensuring multiple processes do not overwrite each other. 
 : To prevent this from occurring, you can specify the expected attribute name and value. If 
 : they match, Amazon SimpleDB performs the update. Otherwise, the update does not occur."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>Using PutAttributes to replace attribute values that do not exist will not result in 
 :     an error response.
 : </li>
 : <li>You cannot specify an empty string as an attribute name.
 : </li>
 : <li>When using eventually consistent reads, a GetAttributes or Select request (read) immediately 
 :     after a DeleteAttributes or PutAttributes request (write) might not return the updated data. 
 :     A consistent read always reflects all writes that received a successful response prior to the 
 :     read. For more information, see Consistency.
 : </li>
 : <li>You can perform the expected conditional check on one attribute per operation.
 : </li>
 : </ul> 
 :
 : <b>LIMITATIONS:</b>
 : <ul>
 : <li>256 total attribute name-value pairs per item</li>
 : <li>One billion attributes per domain</li>
 : <li>10 GB of total user data storage per domain</li>
 : </ul>
 :
 : <b>IMPORTANT:</b> The structure of the parameter $attributes should be as follows:
 :      <attributes>
 :          <attribute>
 :              <name>"attrName"</name>         required, string
 :              <value>"12345"</value>          required, string
 :              <replace>"True"</replace>       optional, boolean
 :              <expected-name>"attrName"</expected-name>       conditional, string
 :              <expected-value>"12345"</expected-value>        conditional, string
 :              <expected-exists>"True"</expected-exists>       conditional, boolean
 :          </attribute>
 :          <attribute>
 :              ...
 :          </attribute>
 :      </attributes>
 :
 :  Description:
 :  <ul>
 :      <li>name: The name of the attribute</li>
 :      <li>value: The value of the attribute</li>
 :      <li>replace: Flag to specify whether to replace the Attribute/Value or to add a new Attribute/Value</li>
 :      <li>expected-name: Name of the attribute to check. 
 :                     <li>Conditions: Must be used with the expected value or expected exists parameter.
 :                                 When used with the expected value parameter, you specify the value to check.
 :                                 When expected exists is set to true and it is used with the expected value 
 :                                 parameter, it performs similarly to just using the expected value parameter. 
 :                                 When expected exists is set to false, the operation is performed if the 
 :                                 expected attribute is not present.
 :                                 Can only be used with single-valued attributes.</li></li>
 :      <li>expected-value: Value of the attribute to check.
 :                      <li>Conditions: Must be used with the expected name parameter. Can be used with the 
 :                                  expected exists parameter if that parameter is set to true.
 :                                  Can only be used with single-valued attributes.</li></li>
 :      <li>expected-exists: Flag to test the existence of an attribute while performing conditional updates.
 :                       <li>Conditions: Must be used with the expected name parameter. When set to true, this must 
 :                                   be used with the expected value parameter. When set to false, this cannot 
 :                                   be used with the expected value parameter.
 :                                   Can only be used with single-valued attributes.</li></li>
 :  </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @param $attributes A sequence of attributes you want to create/replace. Please refer to the function-description for more information about its structure.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:PutAttributesResponse element
:)
declare %ann:sequential function domain:put-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string,
    $attributes as element(attributes)
) as item()* {
    
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="PutAttributes" />,
        <parameter name="ItemName" value="{$item-name}" />,
        
        (:let $counter := 1:)
        for $attribute at $counter in $attributes/attribute
        let $attr-parameters := (
            
            <parameter name="{concat("Attribute.",$counter,".Name")}" value="{$attribute/name/text()}" />,
            <parameter name="{concat("Attribute.",$counter,".Value")}" value="{$attribute/value/text()}" />,
            if ($attribute/replace)
            then
                <parameter name="{concat("Attribute.",$counter,".Replace")}" value="{$attribute/replace/text()}" />
            else (),
            if ($attribute/expected-name)
            then
                <parameter name="{concat("Expected.",$counter,".Name")}" value="{$attribute/expected-name/text()}" />
            else (),
            if ($attribute/expected-value)
            then
                <parameter name="{concat("Expected.",$counter,".Value")}" value="{$attribute/expected-value/text()}" />
            else (),
            if ($attribute/expected-exists)
            then
                <parameter name="{concat("Expected.",$counter,".Exists")}" value="{$attribute/expected-exists/text()}" />
            else ()
         )
         (:let $counter := $counter + 1:)
         return $attr-parameters
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Returns all of the attributes associated with the item. Optionally, the 
 : attributes returned can be limited to one or more specified attribute name parameters.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, 
 : use ConsistentRead. Although this operation might take longer than a standard read, it 
 : always returns the last updated value."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If the item does not exist on the replica that was accessed for this operation, an empty 
 :     set is returned
 : </li>
 : <li>If you specify GetAttributes without any attribute names, all the attributes for the item 
 :     are returned.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:GetAttributesResponse element
:)
declare %ann:sequential function domain:get-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string
) as item()* {

    domain:get-attributes($aws-access-key,$aws-secret,$domain-name,$item-name,(),())

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Returns all of the attributes associated with the item. Optionally, the 
 : attributes returned can be limited to one or more specified attribute name parameters.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, 
 : use ConsistentRead. Although this operation might take longer than a standard read, it 
 : always returns the last updated value."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If the item does not exist on the replica that was accessed for this operation, an empty 
 :     set is returned
 : </li>
 : <li>If you specify GetAttributes without any attribute names, all the attributes for the item 
 :     are returned.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @param $attribute-name The name of the attribute.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:GetAttributesResponse element
:)
declare %ann:sequential function domain:get-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string,
    $attribute-name as xs:string
) as item()* {

    domain:get-attributes($aws-access-key,$aws-secret,$domain-name,$item-name,$attribute-name,())

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Returns all of the attributes associated with the item. Optionally, the 
 : attributes returned can be limited to one or more specified attribute name parameters.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, 
 : use ConsistentRead. Although this operation might take longer than a standard read, it 
 : always returns the last updated value."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If the item does not exist on the replica that was accessed for this operation, an empty 
 :     set is returned
 : </li>
 : <li>If you specify GetAttributes without any attribute names, all the attributes for the item 
 :     are returned.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @param $attribute-name The name of the attribute.
 : @param $consistent-read When set to true, ensures that the most recent data is returned.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:GetAttributesResponse element
:)
declare %ann:sequential function domain:get-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string,
    $attribute-name as xs:string?,
    $consistent-read as xs:string?
) as item()* {
  
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="GetAttributes" />,
        <parameter name="ItemName" value="{$item-name}" />, 
        if ($attribute-name)
            then
                <parameter name="AttributeName" value="{$attribute-name}" />  
            else
                (),
        if ($consistent-read)
            then
                <parameter name="ConsistentRead" value="{$consistent-read}" />  
            else
                ()
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Deletes one or more attributes associated with the item. If all attributes of 
 : an item are deleted, the item is deleted."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If you specify DeleteAttributes without attributes or values, all the attributes for the 
 :     item are deleted.
 : </li>
 : <li>Unless you specify conditions, the DeleteAttributes is an idempotent operation; running 
 :     it multiple times on the same item or attribute does not result in an error response.
 : </li>
 : <li>Conditional deletes are useful for only deleting items and attributes if specific 
 :     conditions are met. If the conditions are met, Amazon SimpleDB performs the delete. 
 :     Otherwise, the data is not deleted.
 : </li>
 : <li>When using eventually consistent reads, a GetAttributes or Select request (read) 
 :     immediately after a DeleteAttributes or PutAttributes request (write) might not return 
 :     the updated data. A consistent read always reflects all writes that received a successful 
 :     response prior to the read. For more information, see Consistency.
 : </li>
 : <li>You can perform the expected conditional check on one attribute per operation.
 : </li>
 : </ul>
 :
 :
 : <b>IMPORTANT:</b> The structure of the OPTIONAL parameter $attributes should be as follows:
 :      <attributes>
 :          <attribute>
 :              <name>"attrName"</name>         optional, string
 :              <value>"12345"</value>          optional, string
 :              <expected-name>"attrName"</expected-name>       conditional, string
 :              <expected-value>"12345"</expected-value>        conditional, string
 :              <expected-exists>"True"</expected-exists>       conditional, boolean
 :          </attribute>
 :          <attribute>
 :              ...
 :          </attribute>
 :      </attributes>
 :
 :  Description:
 :  <ul>
 :      <li>name: The name of the attribute</li>
 :      <li>value: The value of the attribute</li>
 :      <li>replace: Flag to specify whether to replace the Attribute/Value or to add a new Attribute/Value</li>
 :      <li>expected-name: Name of the attribute to check. 
 :                     <li>Conditions: Must be used with the expected value or expected exists parameter.
 :                                 When used with the expected value parameter, you specify the value to check.
 :                                 When expected exists is set to true and it is used with the expected value 
 :                                 parameter, it performs similarly to just using the expected value parameter. 
 :                                 When expected exists is set to false, the operation is performed if the 
 :                                 expected attribute is not present.
 :                                 Can only be used with single-valued attributes.</li></li>
 :      <li>expected-value: Value of the attribute to check.
 :                      <li>Conditions: Must be used with the expected name parameter. Can be used with the 
 :                                  expected exists parameter if that parameter is set to true.
 :                                  Can only be used with single-valued attributes.</li></li>
 :      <li>expected-exists: Flag to test the existence of an attribute while performing conditional updates.
 :                       <li>Conditions: Must be used with the expected name parameter. When set to true, this must 
 :                                   be used with the expected value parameter. When set to false, this cannot 
 :                                   be used with the expected value parameter.
 :                                   Can only be used with single-valued attributes.</li></li>
 :  </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:DeleteAttributesResponse element
:)
declare %ann:sequential function domain:delete-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string
) as item()* {
    
    domain:delete-attributes($aws-access-key,$aws-secret,$domain-name,$item-name,());
    
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Deletes one or more attributes associated with the item. If all attributes of 
 : an item are deleted, the item is deleted."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If you specify DeleteAttributes without attributes or values, all the attributes for the 
 :     item are deleted.
 : </li>
 : <li>Unless you specify conditions, the DeleteAttributes is an idempotent operation; running 
 :     it multiple times on the same item or attribute does not result in an error response.
 : </li>
 : <li>Conditional deletes are useful for only deleting items and attributes if specific 
 :     conditions are met. If the conditions are met, Amazon SimpleDB performs the delete. 
 :     Otherwise, the data is not deleted.
 : </li>
 : <li>When using eventually consistent reads, a GetAttributes or Select request (read) 
 :     immediately after a DeleteAttributes or PutAttributes request (write) might not return 
 :     the updated data. A consistent read always reflects all writes that received a successful 
 :     response prior to the read. For more information, see Consistency.
 : </li>
 : <li>You can perform the expected conditional check on one attribute per operation.
 : </li>
 : </ul>
 :
 :
 : <b>IMPORTANT:</b> The structure of the OPTIONAL parameter $attributes should be as follows:
 :      <attributes>
 :          <attribute>
 :              <name>"attrName"</name>         optional, string
 :              <value>"12345"</value>          optional, string
 :              <expected-name>"attrName"</expected-name>       conditional, string
 :              <expected-value>"12345"</expected-value>        conditional, string
 :              <expected-exists>"True"</expected-exists>       conditional, boolean
 :          </attribute>
 :          <attribute>
 :              ...
 :          </attribute>
 :      </attributes>
 :
 :  Description:
 :  <ul>
 :      <li>name: The name of the attribute</li>
 :      <li>value: The value of the attribute</li>
 :      <li>replace: Flag to specify whether to replace the Attribute/Value or to add a new Attribute/Value</li>
 :      <li>expected-name: Name of the attribute to check. 
 :                     <li>Conditions: Must be used with the expected value or expected exists parameter.
 :                                 When used with the expected value parameter, you specify the value to check.
 :                                 When expected exists is set to true and it is used with the expected value 
 :                                 parameter, it performs similarly to just using the expected value parameter. 
 :                                 When expected exists is set to false, the operation is performed if the 
 :                                 expected attribute is not present.
 :                                 Can only be used with single-valued attributes.</li></li>
 :      <li>expected-value: Value of the attribute to check.
 :                      <li>Conditions: Must be used with the expected name parameter. Can be used with the 
 :                                  expected exists parameter if that parameter is set to true.
 :                                  Can only be used with single-valued attributes.</li></li>
 :      <li>expected-exists: Flag to test the existence of an attribute while performing conditional updates.
 :                       <li>Conditions: Must be used with the expected name parameter. When set to true, this must 
 :                                   be used with the expected value parameter. When set to false, this cannot 
 :                                   be used with the expected value parameter.
 :                                   Can only be used with single-valued attributes.</li></li>
 :  </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $item-name The name of the item.
 : @param $attributes A sequence of attributes you want to delete. Please refer to the function-description for more information about its structure.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:DeleteAttributesResponse element
:)
declare %ann:sequential function domain:delete-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $item-name as xs:string,
    $attributes as element(attributes)?
) as item()* {
    
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="DeleteAttributes" />,
        <parameter name="ItemName" value="{$item-name}" />,
        
        if ($attributes)
        then
            {
                for $attribute at $counter in $attributes/attribute
                let $attr-parameters := (
                    
                    if ($attribute/name)
                    then
                        <parameter name="{concat("Attribute.",$counter,".Name")}" value="{$attribute/name/text()}" />
                    else (),
                    if ($attribute/value)
                    then
                        <parameter name="{concat("Attribute.",$counter,".Value")}" value="{$attribute/value/text()}" />
                    else (),
                    if ($attribute/expected-name)
                    then
                        <parameter name="{concat("Expected.",$counter,".Name")}" value="{$attribute/expected-name/text()}" />
                    else (),
                    if ($attribute/expected-value)
                    then
                        <parameter name="{concat("Expected.",$counter,".Value")}" value="{$attribute/expected-value/text()}" />
                    else (),
                    if ($attribute/expected-exists)
                    then
                        <parameter name="{concat("Expected.",$counter,".Exists")}" value="{$attribute/expected-exists/text()}" />
                    else ()
                 )
                 return $attr-parameters;
             }
         else {}
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The Select operation returns a set of Attributes for ItemNames that match the 
 : select expression. Select is similar to the standard SQL SELECT statement.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, use 
 : ConsistentRead. Although this operation might take longer than a standard read, it always 
 : returns the last updated value.
 :
 : The total size of the response cannot exceed 1 MB. Amazon SimpleDB automatically adjusts the 
 : number of items returned per page to enforce this limit. For example, even if you ask to 
 : retrieve 2500 items, but each individual item is 10 KB in size, the system returns 100 items 
 : and an appropriate next token so you can get the next page of results.
 : 
 : For information on how to construct select expressions, see Using Select to Create Amazon 
 : SimpleDB Queries."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>Operations that run longer than 5 seconds return a time-out error response or a partial 
 :     or empty result set. Partial and empty result sets contains a next token which allow you 
 :     to continue the operation from where it left off.
 : </li>
 : <li>Responses larger than one megabyte return a partial result set.
 : </li>
 : <li>Your application should not excessively retry queries that return RequestTimeout errors. 
 :     If you receive too many RequestTimeout errors, reduce the complexity of your query 
 :     expression.
 : </li>
 : <li>When designing your application, keep in mind that Amazon SimpleDB does not guarantee 
 :     how attributes are ordered in the returned response.
 : </li>
 : <li>For information about limits that affect Select, see Limits.
 : </li>
 : <li>The select operation is case-sensitive.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $select-expression The expression used to query the domain.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:SelectResponse element
:)
declare %ann:sequential function domain:select(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $select-expression as xs:string
) as item()* {

    domain:select($aws-access-key,$aws-secret,$select-expression,(),());

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The Select operation returns a set of Attributes for ItemNames that match the 
 : select expression. Select is similar to the standard SQL SELECT statement.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, use 
 : ConsistentRead. Although this operation might take longer than a standard read, it always 
 : returns the last updated value.
 :
 : The total size of the response cannot exceed 1 MB. Amazon SimpleDB automatically adjusts the 
 : number of items returned per page to enforce this limit. For example, even if you ask to 
 : retrieve 2500 items, but each individual item is 10 KB in size, the system returns 100 items 
 : and an appropriate next token so you can get the next page of results.
 : 
 : For information on how to construct select expressions, see Using Select to Create Amazon 
 : SimpleDB Queries."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>Operations that run longer than 5 seconds return a time-out error response or a partial 
 :     or empty result set. Partial and empty result sets contains a next token which allow you 
 :     to continue the operation from where it left off.
 : </li>
 : <li>Responses larger than one megabyte return a partial result set.
 : </li>
 : <li>Your application should not excessively retry queries that return RequestTimeout errors. 
 :     If you receive too many RequestTimeout errors, reduce the complexity of your query 
 :     expression.
 : </li>
 : <li>When designing your application, keep in mind that Amazon SimpleDB does not guarantee 
 :     how attributes are ordered in the returned response.
 : </li>
 : <li>For information about limits that affect Select, see Limits.
 : </li>
 : <li>The select operation is case-sensitive.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $select-expression The expression used to query the domain.
 : @param $consistent-read When set to true, ensures that the most recent data is returned.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:SelectResponse element
:)
declare %ann:sequential function domain:select(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $select-expression as xs:string,
    $consistent-read as xs:string
) as item()* {

    domain:select($aws-access-key,$aws-secret,$select-expression,$consistent-read,());

};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"The Select operation returns a set of Attributes for ItemNames that match the 
 : select expression. Select is similar to the standard SQL SELECT statement.
 :
 : Amazon SimpleDB keeps multiple copies of each domain. When data is written or updated, all 
 : copies of the data are updated. However, it takes time for the update to propagate to all 
 : storage locations. The data will eventually be consistent, but an immediate read might not 
 : show the change. If eventually consistent reads are not acceptable for your application, use 
 : ConsistentRead. Although this operation might take longer than a standard read, it always 
 : returns the last updated value.
 :
 : The total size of the response cannot exceed 1 MB. Amazon SimpleDB automatically adjusts the 
 : number of items returned per page to enforce this limit. For example, even if you ask to 
 : retrieve 2500 items, but each individual item is 10 KB in size, the system returns 100 items 
 : and an appropriate next token so you can get the next page of results.
 : 
 : For information on how to construct select expressions, see Using Select to Create Amazon 
 : SimpleDB Queries."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>Operations that run longer than 5 seconds return a time-out error response or a partial 
 :     or empty result set. Partial and empty result sets contains a next token which allow you 
 :     to continue the operation from where it left off.
 : </li>
 : <li>Responses larger than one megabyte return a partial result set.
 : </li>
 : <li>Your application should not excessively retry queries that return RequestTimeout errors. 
 :     If you receive too many RequestTimeout errors, reduce the complexity of your query 
 :     expression.
 : </li>
 : <li>When designing your application, keep in mind that Amazon SimpleDB does not guarantee 
 :     how attributes are ordered in the returned response.
 : </li>
 : <li>For information about limits that affect Select, see Limits.
 : </li>
 : <li>The select operation is case-sensitive.
 : </li>
 : </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $select-expression The expression used to query the domain.
 : @param $consistent-read When set to true, ensures that the most recent data is returned.
 : @param $next-token String that tells Amazon SimpleDB where to start the next list of ItemNames.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:SelectResponse element
:)
declare %ann:sequential function domain:select(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $select-expression as xs:string,
    $consistent-read as xs:string?,
    $next-token as xs:string?
) as item()* {
  
    let $parameters := (
        <parameter name="SelectExpression" value="{$select-expression}" />,
        <parameter name="Action" value="Select" />, 
        if ($consistent-read)
            then
                <parameter name="ConsistentRead" value="{$consistent-read}" />  
            else
                (),
        if ($consistent-read)
            then
                <parameter name="NextToken" value="{$next-token}" />  
            else
                ()
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"With the BatchPutAttributes operation, you can perform multiple PutAttribute 
 : operations in a single call. This helps you yield savings in round trips and latencies, and 
 : enables Amazon SimpleDB to optimize requests, which generally yields better throughput.
 : 
 : You can specify attributes and values for items using a combination of the 
 : Item.Y.Attribute.X.Name and Item.Y.Attribute.X.Value parameters. To specify attributes and 
 : values for the first item, you use Item.1.Attribute.1.Name and Item.1.Attribute.1.Value for 
 : the first attribute, Item.1.Attribute.2.Name and Item.1.Attribute.2.Value for the second 
 : attribute, and so on.
 : 
 : To specify attributes and values for the second item, you use Item.2.Attribute.1.Name and 
 : Item.2.Attribute.1.Value for the first attribute, Item.2.Attribute.2.Name and 
 : Item.2.Attribute.2.Value for the second attribute, and so on.
 : 
 : Amazon SimpleDB uniquely identifies attributes in an item by their name/value combinations. 
 : For example, a single item can have the attributes { "first_name", "first_value" } and 
 : { "first_name", second_value" }. However, it cannot have two attribute instances where both 
 : the Item.Y.Attribute.X.Name and Item.Y.Attribute.X.Value are the same.
 : 
 : Optionally, you can supply the Replace parameter for each individual attribute. Setting this 
 : value to true causes the new attribute value to replace the existing attribute value(s) if any 
 : exist. Otherwise, Amazon SimpleDB simply inserts the attribute values. For example, if an item 
 : has the attributes { 'a', '1' }, { 'b', '2'}, and { 'b', '3' } and the requester calls 
 : BatchPutAttributes using the attributes { 'b', '4' } with the Replace parameter set to true, the 
 : final attributes of the item are changed to { 'a', '1' } and { 'b', '4' }. This occurs because 
 : the new 'b' attribute replaces the old value."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>You cannot specify an empty string as an item or attribute name.
 : </li>
 : <li>The BatchPutAttributes operation succeeds or fails in its entirety. There are no partial puts.
 : </li>
 : <li>You can execute multiple BatchPutAttributes operations and other operations in parallel. 
 :     However, large numbers of concurrent BatchPutAttributes calls can result in Service 
 :     Unavailable (503) responses.
 : </li>
 : <li>This operation is vulnerable to exceeding the maximum URL size when making a REST request using 
 :     the HTTP GET method.
 : </li>
 : <li>This operation does not support conditions using Expected.X.Name, Expected.X.Value, or 
 :     Expected.X.Exists.
 : </li>
 : </ul>
 :
 : <b>LIMITATIONS:</b>
 : <ul>
 : <li>256 total attribute name-value pairs per item</li>
 : <li>1 MB request size</li>
 : <li>1 billion attributes per domain</li>
 : <li>10 GB of total user data storage per domain</li>
 : <li>25 item limit per BatchPutAttributes operation</li>
 : </ul>
 :
 : <b>IMPORTANT:</b> The structure of the parameter $attributes should be as follows:
 :      <items>
 :          <item>
 :              <name>"itemName"</name>             required, string
 :              <attributes>
 :                  <attribute>
 :                      <name>"attrName"</name>         required, string
 :                      <value>"12345"</value>          required, string
 :                      <replace>"True"</replace>       optional, boolean
 :                  </attribute>
 :                  <attribute>
 :                      ...
 :                  </attribute>
 :              </attributes>
 :          </item>
 :          <item>
 :              ...
 :          </item>
 :      </items>
 :
 :  Description:
 :  <ul>
 :      <li>(item-)name: The name of the item</li>
 :      <li>(attribute-)name: The name of the attribute</li>
 :      <li>(attribute- value: The value of the attribute</li>
 :      <li>(attribute-)replace: Flag to specify whether to replace the Attribute/Value 
 :                               or to add a new Attribute/Value</li>
 :  </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $items A sequence of items you want to create/replace. Please refer to the function-description for more information about its structure.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:BatchPutAttributesResponse element
:)
declare %ann:sequential function domain:batch-put-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $items as element(items)
) as item()* {
    
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="BatchPutAttributes" />,
        
        for $item at $item-counter in $items/item
        let $item-parameters := (
            
            <parameter name="{concat("Item.",$item-counter,".ItemName")}" value="{$item/name/text()}" />,
            for $attribute at $attr-counter in $item/attributes/attribute
            let $attribute-parameters := (
                
                <parameter name="{concat("Item.",$item-counter,".Attribute.",$attr-counter,".Name")}" value="{$attribute/name/text()}" />,
                <parameter name="{concat("Item.",$item-counter,".Attribute.",$attr-counter,".Value")}" value="{$attribute/value/text()}" />,
                if ($attribute/replace)
                then
                    <parameter name="{concat("Item.",$item-counter,".Attribute.",$attr-counter,".Replace")}" value="{$attribute/replace/text()}" />
                else ()
            )
            return $attribute-parameters
         )
         return $item-parameters
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

(:~
 : Service definition from the Amazon SimpleDB API documentation:
 : <blockquote>"Performs multiple DeleteAttributes operations in a single call, which reduces 
 : round trips and latencies. This enables Amazon SimpleDB to optimize requests, which 
 : generally yields better throughput."</blockquote>
 :
 : <b>NOTE:</b>
 : <ul>
 : <li>If you specify BatchDeleteAttributes without attributes or values, all the attributes 
 :     for the item are deleted.
 : </li> 
 : <li>BatchDeleteAttributes is an idempotent operation; running it multiple times on the 
 :     same item or attribute doesn't result in an error.
 : </li>
 : <li>The BatchDeleteAttributes operation succeeds or fails in its entirety. There are no 
 :     partial deletes.
 : </li>
 : <li>You can execute multiple BatchDeleteAttributes operations and other operations in 
 :     parallel. However, large numbers of concurrent BatchDeleteAttributes calls can result 
 :     in Service Unavailable (503) responses.
 : </li>
 : <li>This operation is vulnerable to exceeding the maximum URL size when making a REST 
 :     request using the HTTP GET method.
 : </li>
 : <li>This operation does not support conditions using Expected.X.Name, Expected.X.Value, 
 :     or Expected.X.Exists.
 : </li>
 : </ul>
 :
 : <b>LIMITATIONS:</b>
 : <ul>
 : <li>1 MB request size</li>
 : <li>25 item limit per BatchPutAttributes operation</li>
 : </ul>
 :
 : <b>IMPORTANT:</b> The structure of the parameter $attributes should be as follows:
 :      <items>
 :          <item>
 :              <name>"itemName"</name>             required, string
 :              <attributes>
 :                  <attribute>
 :                      <name>"attrName"</name>         required, string
 :                      <value>"12345"</value>          required, string
 :                  </attribute>
 :                  <attribute>
 :                      ...
 :                  </attribute>
 :              </attributes>
 :          </item>
 :          <item>
 :              ...
 :          </item>
 :      </items>
 :
 :  Description:
 :  <ul>
 :      <li>(item-)name: The name of the item</li>
 :      <li>(attribute-)name: The name of the attribute</li>
 :      <li>(attribute- value: The value of the attribute</li>
 :  </ul>
 :
 :
 : @param $aws-access-key Your personal "AWS Access Key" that you can get from your amazon account 
 : @param $aws-secret Your personal "AWS Secret" that you can get from your amazon account
 : @param $domain-name The name of the domain.
 : @param $items A sequence of items you want to delete. Please refer to the function-description for more information about its structure.
 : @return returns a pair of 2 items. The first is the http response information; the second is the response document containing
 :         the aws:BatchDeleteAttributesResponse element
:)
declare %ann:sequential function domain:batch-delete-attributes(
    $aws-access-key as xs:string, 
    $aws-secret as xs:string,
    $domain-name as xs:string,
    $items as element(items)
) as item()* {
    
    let $parameters := (
        <parameter name="DomainName" value="{$domain-name}" />,
        <parameter name="Action" value="BatchDeleteAttributes" />,
        
        for $item at $item-counter in $items/item
        let $item-parameters := (
            
            <parameter name="{concat("Item.",$item-counter,".ItemName")}" value="{$item/name/text()}" />,
            for $attribute at $attr-counter in $item/attributes/attribute
            let $attribute-parameters := (
                
                <parameter name="{concat("Item.",$item-counter,".Attribute.",$attr-counter,".Name")}" value="{$attribute/name/text()}" />,
                <parameter name="{concat("Item.",$item-counter,".Attribute.",$attr-counter,".Value")}" value="{$attribute/value/text()}" />
            )
            return $attribute-parameters 
         )
         return $item-parameters
    )
    let $request := request:create("GET",$domain:href,$parameters)
    return 
        {
            (: sign the request :)
            request:sign-v2(
                $request,
                $domain:host,
                $domain:path,
                $domain:version,
                $parameters,
                $aws-access-key,
                $aws-secret);
                
            sdb_request:send($request)
        }
};

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
 :      This test prepares to create a subscription by sending the endpoint a confirmation message.
 :
 :      NOTE: The endpoint owner must call the ConfirmSubscription action with the token from the 
 :            confirmation message. There are three possibilities to do so:
 :              - run /particular-tests/topic_confirm_subscription.xq 
 :              - if you are using the test-suite, run part two
 :              - if you´ve choosen the protocol "email", use the link it comes with
 :      NOTE: Confirmation tokens are valid for 24 hours.
 :      
 :      IMPORTANT:
 :      @param $testconfig should contain at least the following data to pass this test:
 :                              aws-key: Your AWS-Key
 :                              aws-secret: Your AWS-Secret
 :                              topic-arn: The ARN of the topic you want to subscribe to
 :                              protocol: The protocol you want to use. Supported protocols are:
 :                                          - http -- delivery of JSON-encoded message via HTTP POST
 :                                          - https -- delivery of JSON-encoded message via HTTPS POST
 :                                          - email -- delivery of message via SMTP
 :                                          - email-json -- delivery of JSON-encoded message via SMTP
 :                                          - sqs -- delivery of JSON-encoded message to an Amazon SQS queue
 :                              endpoint: The Endpoint you want to receive notifications. Endpoints vary by protocol:
 :                                          - For the http protocol, the endpoint is an URL beginning with "http://"
 :                                          - For the https protocol, the endpoint is a URL beginning with "https://"
 :                                          - For the email protocol, the endpoint is an e-mail address
 :                                          - For the email-json protocol, the endpoint is an e-mail address
 :                                          - For the sqs protocol, the endpoint is the ARN of an Amazon SQS queue
 : </p>
 :
 : @author Klaus Wichmann klaus [at] xquery [dot] co [dot] uk
 :)
module namespace test = 'http://test/xaws/sns/particular_tests/subscribe';

import module namespace topic = 'http://www.xquery.me/modules/xaws/sns/topic' at '/uk/co/xquery/www/modules/xaws/sns/topic.xq';
import module namespace error = 'http://www.xquery.me/modules/xaws/helpers/error' at '/uk/co/xquery/www/modules/xaws/helpers/error.xq';
import module namespace util = 'http://www.xquery.me/modules/xaws/helpers/utils' at '/uk/co/xquery/www/modules/xaws/helpers/utils.xq';

import module namespace http = "http://expath.org/ns/http-client";
import module namespace ser = "http://www.zorba-xquery.com/modules/serialize";
import module namespace hash = "http://www.zorba-xquery.com/modules/security/hash";

declare namespace aws = "http://sns.amazonaws.com/doc/2010-03-31/";

declare sequential function test:run($testconfig as element(config),$testresult as element(testresult)) as element(testresult) {
    declare $success := false();
    declare $msg := ();
    declare $testname := "sns_subscribe";
    
    declare $aws-key := string($testconfig/aws-key/text());
    declare $aws-secret := string($testconfig/aws-secret/text());
    declare $topic-arn := string($testconfig/topic-arn/text());
    declare $protocol := string($testconfig/protocol/text());
    declare $endpoint := string($testconfig/endpoint/text());
        
    declare $response;
    
    try {
        
        (: send the subscription :)
        topic:subscribe($aws-key, $aws-secret, $topic-arn, $protocol, $endpoint);
        
        set $success := true();
        set $msg := "Confirmation-Token created and sent to the Endpoint";
                
    } catch * ($code,$message,$obj) { 
        set $msg := error:to-string($code,$message,$obj);
    };
   
    insert nodes (
                    <particular_test name="{$testname}" success="{$success}">
                        <result>{$msg}</result>
                    </particular_test>
    ) as last into $testresult;
    $testresult;
};

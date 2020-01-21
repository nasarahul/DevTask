/*********************************************************************************
 *** @ClassName         : TransactionItemTriggerHandler 
 *** @Author            : Rahul Nasa 
 *** @Requirement       : TransactionItemTriggerHandlerTest class for methods related to TransactionTrigerHandlerClass
 *** @Created date      : 21/01/2020
 *** @Modified by       : Rahul Nasa
 *** @modified date     : 21/01/2020   
 **********************************************************************************/

@isTest class TransactionItemTriggerHandlerTest {
    // Simple echo callout class
    // Returns whatever response we tell it to when asked
    class EchoHttpMock implements HttpCalloutMock {
        HttpResponse res;
        EchoHttpMock(HttpResponse r) {
            res = r;
        }
        // This is the HttpCalloutMock interface method
        public HttpResponse respond(HttpRequest req) {
            return res;
        }
    }

    @isTest static void test() {
        // Avoid using live data
        List<Transaction__c> transactions = new List<Transaction__c>{ new Transaction__c(Name='T01',Total_Cost_c__c=100.00,Total_Discount_c__c = 20.00,Transaction_Count_c__c=1) };
        insert transactions ;
        List<TransactionItem__c> transactionItems = new List<TransactionItem__c>{ new TransactionItem__c(Name='TI-01',Item_Cost_c__c=100.00,Transaction__c=transactions[0].Id) };
        insert transactionItems ;
        // We tell it what to simulate
        HttpResponse res = new HttpResponse();
        res.setBody('<?xml version="1.0" encoding="utf-8"?><root U_Id="12345"></root>');
        res.setStatusCode(200);
        // This allows the callout to succeed
        Test.setMock(HttpCalloutMock.class, new EchoHttpMock(res));
        // Start the test
        Test.startTest();
        // Enqueue the future call
        TransactionItemTriggerHandler.afterInsert(transactionItems );
        // Trigger future method
        Test.stopTest();
        // Verify logic
     //   leads = [select id__c from lead];
       // System.assertEquals('12345', leads[0].Id__c);
    }
}
/*********************************************************************************
 *** @ClassName         : TransactionItemTriggerHandler 
 *** @Author            : Rahul Nasa 
 *** @Requirement       : TransactionItemTriggerHandler class for methods related to API calls
 *** @Created date      : 20/01/2020
 *** @Modified by       : Rahul Nasa
 *** @modified date     : 20/01/2020   
 **********************************************************************************/
public class TransactionItemTriggerHandler {

    //AfterInsert method that is called from the TransactionItemTrigger
    public static void afterInsert(List<TransactionItem__c> lstTItem)
    {
        set<Id> setTransationItem = new set<Id>();
        system.debug('lstTItem-->' + lstTItem);
        //To capture the set Of Transactions from Transaction Items
        for(TransactionItem__c objTItem : lstTItem)
        {
           setTransationItem.add(objTItem.Transaction__c);  
        }
        //Set of Transaction is passed due to future call  
        system.debug('setTransationItem-->' + setTransationItem);      
        sendTItemInfo(setTransationItem);
    }
     
    @future (callout=true)
    public static void sendTItemInfo(set<Id> pTransaction) {
        try{
            for(Transaction__c objTransaction : [select Id, Total_Cost_c__c,Total_Discount_c__c, Transaction_Count_c__c,(Select Id, Item_Cost_c__c, Name from Transaction_Items__r) from Transaction__c where id in:pTransaction ])
            {
                system.debug('objTransaction.Transaction_Count_c__c -->' + objTransaction.Transaction_Count_c__c);
                system.debug('objTransaction.Transaction_Items__r.size() -->' + objTransaction.Transaction_Items__r.size());
                //Condition to check that number of TrnscationItems count is same as Transcation Count field in Trnsaction record.
                if(objTransaction.Transaction_Count_c__c == objTransaction.Transaction_Items__r.size())
                {
                //Ist API Request
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    request.setEndpoint('Endpoint URL1');
                    request.setHeader('Content-Type','application/json'); 
                    request.setMethod('POST');
                    request.setBody('[' + '\n');
                    for(integer i=0; i<objTransaction.Transaction_Items__r.size();i++)
                    {
                        TransactionItem__c objTItems = objTransaction.Transaction_Items__r[i];
                        request.setBody('{'+ '\n');
                        request.setBody('"keys": {' + '\n');
                        request.setBody('"TransactionItemID":' +  string.valueOf(objTItems.Id));
                        request.setBody('},' + '\n');
                        request.setBody('"values": {'+'\n');
                        request.setBody('"ItemCost":' + string.valueOf(objTItems.Item_Cost_c__c) +','+'\n');
                        request.setBody('"ItemName":' + string.valueOf(objTItems.Name) + '\n');
                        request.setBody('}' + '\n');
                        system.debug('i-->' + i);
                        if(i != objTransaction.Transaction_Items__r.size())
                           request.setBody('}'); 
                        else
                           request.setBody('},');
                        system.debug('i-->###' + i);
                    }                
                    request.setBody(']');
        
                    request.setCompressed(true);
                    system.debug('request-->' + request); 
                    response = http.send(request);
                    if (response.getStatusCode() == 200) {
                        
                       //If first is successfull then Second API call 
                        HttpRequest requestParent = new HttpRequest();
                        HttpResponse responseParent = new HttpResponse();
                        Http httpParent = new Http();
                         
                        requestParent.setEndpoint('Endpoint URL1');
                        requestParent.setHeader('Content-Type','application/json'); 
                        requestParent.setMethod('POST');            
                        requestParent.setBody('{'+ '\n');
                        requestParent.setBody('"keys": {' + '\n');
                        requestParent.setBody('"TransactionID":' + string.valueOf(objTransaction.Id));
                        requestParent.setBody('},' + '\n');
                        requestParent.setBody('"values": {'+'\n');
                        requestParent.setBody('"TotalCost":' + string.valueOf(objTransaction.Total_Cost_c__c) +','+'\n');
                        requestParent.setBody('"TotalDiscount":' + string.valueOf(objTransaction.Total_Discount_c__c) +',' + '\n');
                        requestParent.setBody('"TransactionDate":'  + string.valueOf(system.today()) + '\n');
                        requestParent.setBody('}' + '\n');
                        requestParent.setBody('}');
                        
            
                        requestParent.setCompressed(true);
                         
                        responseParent = httpParent.send(requestParent);
                        if (responseParent.getStatusCode() == 200) {
                            System.debug('Response-' + responseParent);
                        }
                    }
                }
            
            }
        }
        catch(System.CalloutException e){
            System.debug('Error-' + e.getMessage());   
        }
    }
}

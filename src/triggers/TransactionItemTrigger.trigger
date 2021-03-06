/*********************************************************************************
 *** @TriggerName         : TransactionItemTrigger 
 *** @Author            : Rahul Nasa 
 *** @Requirement       : TransactionItemTrigger for methods related to API calls
 *** @Created date      : 20/01/2020
 *** @Modified by       : Rahul Nasa
 *** @modified date     : 20/01/2020   
 **********************************************************************************/
trigger TransactionItemTrigger on TransactionItem__c (after Insert) {
    //After Insert Trigger to call the helper class
    if(trigger.Isafter && trigger.isInsert)
    {
            TransactionItemTriggerHandler.afterInsert(trigger.new);
    }

}
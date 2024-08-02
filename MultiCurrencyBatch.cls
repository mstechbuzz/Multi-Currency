global with sharing class MultiCurrencyBatch implements Database.Batchable<sObject>,   
Database.AllowsCallouts {
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select Id, ConversionRate, IsoCode, IsCorporate from CurrencyType where IsActive = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CurrencyType> currencyList){
        if(!currencyList.isEmpty()){
            MultiCurrencyBatchHelper.updateCurrencyRates(currencyList);
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug('Batch is complete');
    }
}
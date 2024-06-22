public with sharing class CustomerPortfolioTriggerHandler implements TriggerHandler {
    public void beforeInsert() { 
        CustomerPortfolioBO.validateCustomPortfolios(Trigger.new);
        CustomerPortfolioBO.updateSourceField(Trigger.new);
    }
    
    public void beforeUpdate() { 
        CustomerPortfolioBO.validateCustomPortfolios(Trigger.new);
        CustomerPortfolioBO.updateSourceField(Trigger.new);
    }

    public void beforeDelete() { }
    
    public void afterInsert() { 
        CustomerPortfolioSharingRules.createCustomShareRecords(Trigger.new, null);
    }
    
    public void afterUpdate() {
        CustomerPortfolioSharingRules.deleteCustomShareRecords((Map<Id, CustomerPortfolio__c>)Trigger.newMap, Trigger.old);
        CustomerPortfolioSharingRules.createCustomShareRecords(Trigger.new, (Map<Id, CustomerPortfolio__c>)Trigger.oldMap);
    }

    public void afterDelete() { 
        CustomerPortfolioSharingRules.deleteCustomShareRecords(null, Trigger.old);
    }
}
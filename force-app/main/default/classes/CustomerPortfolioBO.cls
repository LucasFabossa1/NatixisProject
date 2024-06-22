public with sharing class CustomerPortfolioBO {
    
    public static void updateSourceField(List<CustomerPortfolio__c> customerPortfolios) {
        for (CustomerPortfolio__c cp : customerPortfolios) {
            cp.Source__c = String.isBlank(cp.ExternalId__c) ? 'Internal' : 'External';
        }
    }

    public static void validateCustomPortfolios(List<CustomerPortfolio__c> customerPortfolios) {
        Map<Id, Map<Id, CustomerPortfolio__c>> mapPortfolios = new Map<Id, Map<Id, CustomerPortfolio__c>>();

        Set<Id> accountIds = new Set<Id>();
        for (CustomerPortfolio__c cp : customerPortfolios) {
            if (!mapPortfolios.containsKey(cp.User__c)) {
                mapPortfolios.put(cp.User__c, new Map<Id, CustomerPortfolio__c>());
            }
            mapPortfolios.get(cp.User__c).put(cp.Account__c, cp);

            accountIds.add(cp.Account__c);
        }

        for (CustomerPortfolio__c cp : [SELECT Id, User__c, Account__c FROM CustomerPortfolio__c WHERE User__c IN: mapPortfolios.keySet() AND Account__c IN: accountIds]) {
            if (mapPortfolios.containsKey(cp.User__c) && mapPortfolios.get(cp.User__c).containsKey(cp.Account__c) && cp.Id != mapPortfolios.get(cp.User__c).get(cp.Account__c).Id) {
                mapPortfolios.get(cp.User__c).get(cp.Account__c).addError(Label.Duplicated_Custom_Portflio);
            }
        }
    }
}
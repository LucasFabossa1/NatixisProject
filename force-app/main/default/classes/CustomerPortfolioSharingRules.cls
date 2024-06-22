public without sharing class CustomerPortfolioSharingRules {
    
    public static void deleteCustomShareRecords(Map<Id, CustomerPortfolio__c> newMap, List<CustomerPortfolio__c> oldList) {
        Map<Id, Set<Id>> customPortfolioShareToDelete = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountShareToDelete = new Map<Id, Set<Id>>();

        for (CustomerPortfolio__c cp : oldList) { 

            if (newMap == null) {
                if (cp.Account__c != null) {
                    updateMapToDelete(accountShareToDelete, cp.User__c, cp.Account__c);
                }
            }
            else {
                if (cp.User__c != newMap.get(cp.Id).User__c) {

                    if (cp.User__c != null) {
                        updateMapToDelete(customPortfolioShareToDelete, cp.User__c, cp.Id);
                    }
    
                    if (cp.Account__c != null) {
                        updateMapToDelete(accountShareToDelete, cp.User__c, cp.Account__c);
                    }
                }
    
                if (cp.Account__c != newMap.get(cp.Id).Account__c) {
    
                    if (cp.User__c != null && cp.Account__c != null) {
                        updateMapToDelete(accountShareToDelete, cp.User__c, cp.Account__c);
                    }
                }
            }            
        }

        deleteShareRecords(customPortfolioShareToDelete, accountShareToDelete);
    }

    public static void createCustomShareRecords(List<CustomerPortfolio__c> customerPortfolios, Map<Id, CustomerPortfolio__c> oldMap) {

        List<CustomerPortfolio__Share> newSharePortfolios = new List<CustomerPortfolio__Share>();
        List<AccountShare> newShareAccounts = new List<AccountShare>();

        for (CustomerPortfolio__c cp : customerPortfolios) {

            if (oldMap == null) {
                newSharePortfolios.add(createCustomPortfolioShare(cp));
                newShareAccounts.add(createAccountShare(cp));
            }
            else if (oldMap.containsKey(cp.Id)) {
                if (cp.User__c != oldMap.get(cp.Id).User__c) {

                    if (cp.User__c != null) {
                        newSharePortfolios.add(createCustomPortfolioShare(cp));
                    }

                    if (cp.Account__c != null) {
                        newShareAccounts.add(createAccountShare(cp));
                    }
                }

                if (cp.Account__c != oldMap.get(cp.Id).Account__c) {
                    if (cp.Account__c != null && cp.User__c != null) {
                        newShareAccounts.add(createAccountShare(cp));
                    }
                }
            }
        }

        insertNewShareRecords(newSharePortfolios, newShareAccounts);
    }

    private static void insertNewShareRecords(List<CustomerPortfolio__Share> newSharePortfolios, List<AccountShare> newShareAccounts) {
        List<SObject> shareRecordsToInsert = new List<SObject>();

        if (!newShareAccounts.isEmpty()) {
            shareRecordsToInsert.addAll(newShareAccounts);
        }

        if (!newSharePortfolios.isEmpty()) {
            shareRecordsToInsert.addAll(newSharePortfolios);
        }

        if (!shareRecordsToInsert.isEmpty()) {
            insert shareRecordsToInsert;
        }
    }

    private static void deleteShareRecords(Map<Id, Set<Id>> portfolioShareToDelete, Map<Id, Set<Id>> accountShareToDelete) {
        List<SObject> shareRecordsToDelete = new List<SObject>();
        shareRecordsToDelete.addAll(getShareRecordsToDelete(portfolioShareToDelete, 'CustomerPortfolio__Share', 'ParentId'));
        shareRecordsToDelete.addAll(getShareRecordsToDelete(accountShareToDelete, 'AccountShare', 'AccountId'));
        
        if (!shareRecordsToDelete.isEmpty()) {
            Database.delete(shareRecordsToDelete, false);
        }
    }

    private static List<SObject> getShareRecordsToDelete(Map<Id, Set<Id>> shareRecordToDelete, String shareObject, String parentField) {

        Set<Id> parentRecordIds = new Set<Id>();
        for (Id userId : shareRecordToDelete.keySet()) {
            parentRecordIds.addAll(shareRecordToDelete.get(userId));
        }

        Set<Id> userIds = shareRecordToDelete.keySet();
        List<SObject> toDelete = new List<SObject>();
        String query = 'SELECT Id, UserOrGroupId, {0} FROM {1} WHERE UserOrGroupId IN: userIds AND {0} IN: parentRecordIds';
        query = String.format(query, new List<String> {parentField, shareObject});

        for (SObject shareRecord : Database.query(query)) {
            if (shareRecordToDelete.get((Id)shareRecord.get('UserOrGroupId')).contains((Id)shareRecord.get(parentField))) {
                toDelete.add(shareRecord);
            }
        }

        return toDelete;
    }

    private static void updateMapToDelete(Map<Id, Set<Id>> mapToDelete, Id key, Id value) {
        if (!mapToDelete.containsKey(key)) {
            mapToDelete.put(key, new Set<Id>());
        }
        mapToDelete.get(key).add(value);
    }

    private static CustomerPortfolio__Share createCustomPortfolioShare(CustomerPortfolio__c cp) {
        return new CustomerPortfolio__Share(
            AccessLevel = 'Edit',
            ParentId = cp.Id,
            UserOrGroupId = cp.User__c
        );
    } 

    private static AccountShare createAccountShare(CustomerPortfolio__c cp) {
        return new AccountShare(
            AccountAccessLevel = 'Edit',
            AccountId = cp.Account__c,
            UserOrGroupId = cp.User__c,
            CaseAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read'
        );
    }
}
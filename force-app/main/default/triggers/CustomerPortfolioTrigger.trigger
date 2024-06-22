trigger CustomerPortfolioTrigger on CustomerPortfolio__c (before insert, after insert, before update, after update, before delete, after delete) {
	TriggerHandlerFactory.execute(CustomerPortfolioTriggerHandler.class);
}
@isTest
public with sharing class MapTest {

	public static testmethod void testgetSelectedRecord(){
		Account acc = new Account();
		acc.Name = 'TestAccount';
		acc.BillingStreet = '111 S State St';
		acc.BillingCity = 'Chicago';
		acc.BillingState = 'IL';

		insert acc;

		List<Account> accList = [SELECT Id from Account WHERE Name = 'TestAccount' LIMIT 1];

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
			String resultsString = MapController.getSelectedRecord(accList[0].Id, 'BillingAddress');

		Test.stopTest();

		Map<String,Object> resultsMap = (Map<String,Object>)JSON.deserializeUntyped(resultsString);

		System.assertEquals(true, resultsMap.get('apiDetails') != null);
	}

	public static testmethod void testGetSelectedRecordWithoutGeolocation(){
		Account acc = new Account();
		acc.Name = 'TestAccount';
		acc.BillingStreet = '111 S State St';
		acc.BillingCity = 'Chicago';
		acc.BillingState = 'IL';

		insert acc;

		List<Account> accList = [SELECT Id from Account WHERE Name = 'TestAccount' LIMIT 1];

		String resultsString = MapController.getSelectedRecordWithoutGeolocation(accList[0].Id, 'BillingAddress');

		Map<String,Object> resultsMap = (Map<String,Object>)JSON.deserializeUntyped(resultsString);

		System.assertEquals(true, resultsMap.get('addressString') != null);
	}

}
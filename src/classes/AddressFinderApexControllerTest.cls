@isTest
private class AddressFinderApexControllerTest {
	
		@isTest static void test_null_config() {
				//No Config__C object
				System.assertEquals(null, AddressFinderApexController.getConfigKey());
				System.assertEquals(null, AddressFinderApexController.getConfigCountryCode());
		}
		
		@isTest static void test_empty_config() {
				insert new Config__C(Name='name', Key__c=null, Country_Code__c=null);
				System.assertEquals(null, AddressFinderApexController.getConfigKey());
				System.assertEquals(null, AddressFinderApexController.getConfigCountryCode());
		}
		
		@isTest static void test_correct_config() {
				insert new Config__C(Name='name', Key__c='zzz', Country_Code__c='nz');
				System.assertEquals('zzz', AddressFinderApexController.getConfigKey());
				System.assertEquals('nz', AddressFinderApexController.getConfigCountryCode());
		}
		
		@isTest static void test_version() {
				System.assertNotEquals(null, AddressFinderApexController.getAppVersion());
		}
		
		@isTest static void test_fetch_user_object() {
				User user = TestUserFactory.createTestUser();
				System.assertEquals(user.Id, AddressFinderApexController.fetchRecordObject(user.Id, true).Id);
		}
		
		@isTest static void test_fetch_account_object() {
				Account account = TestUserFactory.createTestAccount();
				Sobject s = AddressFinderApexController.fetchRecordObject(account.Id, true);
				String json = System.JSON.serialize(s);
				System.assertEquals(true, json.contains('27 Billing Street'));
		}
		
		@isTest static void test_fetch_contact_object() {
				Contact c = TestUserFactory.createTestContact();
				Sobject s = AddressFinderApexController.fetchRecordObject(c.Id, true);
				String json = System.JSON.serialize(s);
				System.assertEquals(true, json.contains('27 Mailing Street'));
		}
		
		@isTest static void test_fetch_null_object() {
				Sobject s = AddressFinderApexController.fetchRecordObject(null, true);
				System.assertEquals(null, s);
		}
		
		@isTest static void test_persist_user_address() {
				User user = TestUserFactory.createTestUser();
				String address = '{ "street" : "221B Baker Street", "city" : "London"}';
				User persisted = (User)AddressFinderApexController.persistAddress(address, 'Address', user.Id);
				System.assertEquals(persisted.street, '221B Baker Street');
				System.assertEquals(persisted.city, 'London');
		}
		
		@isTest static void test_persist_account_address() {
				Account account = TestUserFactory.createTestAccount();
				String address = '{ "street" : "221B Baker Street", "city" : "London"}';
				Account persisted = (Account)AddressFinderApexController.persistAddress(address, 'BillingAddress', account.Id);
				System.assertEquals(persisted.BillingStreet, '221B Baker Street');
				System.assertEquals(persisted.BillingCity, 'London');
		}
		
		@isTest static void test_getAddressTypes() {
				User user = TestUserFactory.createTestUser();
				List<String> addressTypes = AddressFinderApexController.getAddressTypesForRecord(user.Id);
				System.assertEquals(addressTypes.size(), 1);
				System.assertEquals(addressTypes[0], 'Address');
		}
		
		@isTest static void test_getFieldsToShow() {
			List<String> fieldsToShow = AddressFinderApexController.getFieldsToShow('User', true);
			System.assertEquals(fieldsToShow[0], 'Address');
		}
		
		@isTest static void test_getPrefixTypes() {
			List<String> p = AddressFinderApexController.getPrefixTypesForObject('NonObject');
			System.assertEquals(0, p.size());
		}
		
		@isTest static void test_fetchRecordAddresses() {
			User c = TestUserFactory.createTestUser();
			Map<String, Object> m = AddressFinderApexController.fetchRecordAddresses(c.Id, true);
			System.assertEquals(1, m.size());
			// System.assertEquals(true, s.contains('"MailingAddress":'));
		}

}
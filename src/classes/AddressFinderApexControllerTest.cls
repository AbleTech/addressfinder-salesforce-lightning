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
}
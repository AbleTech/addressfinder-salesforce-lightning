@isTest
public class TestUserFactory {
		 
		 public static User createTestUser() {
			 Profile p = [select Id, Name from Profile where Name = 'Standard User' limit 1];

       Double hash = Double.valueOf(System.now().millisecond());
       User u = new User(alias =  'TestUser',
         email='mockuser@mockmail.com',
         emailencodingkey='UTF-8', lastname='Testing',
         languagelocalekey='en_US', localesidkey='en_US',
         profileid = p.Id,
         timezonesidkey='America/Los_Angeles', username=  String.valueOf(hash) + 'mockuser@mockmail.com');
       insert u;
			 return u;
		 }
		 
		 public static Account createTestAccount() {
			 Account a = new Account(Name='TestAccount');
			 a.BillingStreet='27 Billing Street';
			 a.BillingCity='Billing';
			 a.ShippingStreet='27 Shipping Street';
			 a.ShippingCity='Shipping';
			 insert a;
			 return a;
		 }
		 
		 public static Contact createTestContact() {
			 Account a = createTestAccount();
			 Contact c = new Contact(firstname='TestFirstName', lastname='TestLastName', AccountId=a.id);
			 c.MailingStreet='27 Mailing Street';
			 c.MailingCity='Mailing';
			 insert c;
			 return c;
		 }
}
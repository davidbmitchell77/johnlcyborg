@isTest
private class ContactTriggerTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            Name    = 'Test Account',
            Phone   = '(000) 000-0000',
            Website = 'www.foobar.com'
        );
        insert a;
    }

    @isTest
    private static void test01_insert() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Contact c = new Contact(
            Salutation  = 'Mr.',
            FirstName   = 'Test',
            LastName    = 'Contact #1',
            Title       = 'Supervisor',
            Description = 'Test Contact #1',
            Email       = 'test.contact1@foobar.com',
            Phone       = '(111) 111-1111',
            AccountId   = a.Id
        );
        Test.startTest();
        insert c;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
    }

    @isTest
    private static void test02_update() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Contact c = new Contact(
            Salutation  = 'Mr.',
            FirstName   = 'Test',
            LastName    = 'Contact #2',
            Title       = 'Supervisor',
            Description = 'Test Contact #2',
            Email       = 'test.contact2@foobar.com',
            Phone       = '(222) 222-2222',
            AccountId   = a.Id
        );
        Test.startTest();
        insert c;
        c.Salutation = 'Ms.';
        update c;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        System.assertEquals('Ms.', [SELECT Id, Salutation FROM Contact WHERE AccountId = :a.Id LIMIT 1].Salutation);
    }

    @isTest
    private static void test03_delete() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Contact c = new Contact(
            Salutation  = 'Mrs.',
            FirstName   = 'Test',
            LastName    = 'Contact #3',
            Title       = 'Supervisor',
            Description = 'Test Contact #3',
            Email       = 'test.contact3@foobar.com',
            Phone       = '(333) 333-3333',
            AccountId   = a.Id
        );
        Test.startTest();
        insert c;
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        delete c;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Contact]);
    }

    @isTest
    private static void test04_undelete() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Contact c = new Contact(
            Salutation  = 'Dr.',
            FirstName   = 'Test',
            LastName    = 'Contact #4',
            Title       = 'Supervisor',
            Description = 'Test Contact #4',
            Email       = 'test.contact4@foobar.com',
            Phone       = '(444) 444-4444',
            AccountId   = a.Id
        );
        Test.startTest();
        insert c;
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
        delete c;
        System.assertEquals(0, [SELECT COUNT() FROM Contact]);
        undelete c;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Contact]);
    }

    @isTest
    private static void test05_validate() {
        Account a = [SELECT Id, Name, Phone, Website FROM Account LIMIT 1];
        Contact c = new Contact(
            Salutation  = 'Prof.',
            FirstName   = 'Test',
            LastName    = 'Contact #5',
            Title       = 'Supervisor',
            Description = 'Test Contact #5',
            Email       = 'test.contact5@foobar.com',
            Phone       = null,
            AccountId   = a.Id
        );
        Test.startTest();
        try {
            insert c;
        }
        catch(Exception e) {
            System.debug(LoggingLevel.WARN, 'ContactTriggerTest.test05_validate(): ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Contact]);
    }
}
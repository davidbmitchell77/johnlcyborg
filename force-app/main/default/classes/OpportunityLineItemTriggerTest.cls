@isTest
private class OpportunityLineItemTriggerTest {
    @TestSetup
    private static void dataFactory() {
        Account a = new Account(
            Name    = 'Test Account',
            Phone   = '(000) 000-0000',
            Website = 'www.testaccount.com'
        );
        insert a;
        Opportunity o = new Opportunity(
            Name        = 'Test Opportunity #1',
            Description = 'FOR TESTING PURPOSES ONLY.',
            StageName   = 'Prospecting',
            Amount      = 100000.00,
            Probability = 100,
            Type        = 'New Business',
            CloseDate   = Date.today().addDays(28),
            AccountId   = a.Id
        );
        insert o;
        Product2 p = new Product2(
            Name     = 'Test Product',
            IsActive = true
        );
        insert p;
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = p.Id,
            UnitPrice    = 100.00,
            IsActive     = true
        );
        insert pbe;
    }

    @isTest
    private static void test01_insert() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name FROM PricebookEntry LIMIT 1];
        Test.startTest();
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 5.00,
            UnitPrice        = 100.00
        );
        insert li;
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(1, [SELECT Id, LineItem__c FROM OpportunityLineItem LIMIT 1].LineItem__c);
        System.assertEquals(1, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
    }

    @isTest
    private static void test02_update() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name FROM PricebookEntry LIMIT 1];
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 5.00,
            UnitPrice        = 100.00
        );
        insert li;
        System.assertEquals(500.00, [SELECT Id, TotalPrice FROM OpportunityLineItem].Totalprice);
        Test.startTest();
        li.Quantity = 10.00;
        update li;
        Test.stopTest();
        System.assertEquals(1000.00, [SELECT Id, TotalPrice FROM OpportunityLineItem].Totalprice);
    }

    @isTest
    private static void test03_delete() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name FROM PricebookEntry LIMIT 1];
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 5.00,
            UnitPrice        = 100.00
        );
        insert li;
        System.assertEquals(1, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(1, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
        Test.startTest();
        delete li;
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(0, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
    }

    @isTest
    private static void test04_validate() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name FROM PricebookEntry LIMIT 1];
        Test.startTest();
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            Quantity         = 0.00,
            UnitPrice        = 100.00
        );
        try {
            insert li;
        }
        catch(DmlException e) {
            System.debug(LoggingLevel.ERROR, ('OpportunityLineItemTriggerTest.test04_validate: ' + e.getDmlType(0) + '|' + e.getDmlMessage(0)));
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :o.Id]);
    }
}
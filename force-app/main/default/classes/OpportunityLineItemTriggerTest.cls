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
        List<Product2> products = new List<Product2>();
        for (Integer i=1; i<=10; i++) {
            Product2 p = new Product2(
                Name     = 'Test Product #' + i,
                IsActive = true
            );
            products.add(p);
        }
        insert products;
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        for (Integer i=0; i<10; i++) {
            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id   = products[i].Id,
                UnitPrice    = (100.00 * (i + 1)),
                IsActive     = true
            );
            priceBookEntries.add(pbe);
        }
        insert priceBookEntries;
    }

    @isTest
    private static void test01_insert() {
        Account     a             = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o             = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry];
        Test.startTest();
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (Integer i=0; i<9; i++) {
            OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId    = o.Id,
                PricebookEntryId = pbes[i].Id,
                UnitPrice        = pbes[i].UnitPrice,
                Quantity         = (100 * (i + 1))
            );
            lineItems.add(li);
        }
        insert lineItems;
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbes[lineItems.size()].Id,
            UnitPrice        = pbes[lineItems.size()].UnitPrice,
            Quantity         = (100 * (lineItems.size() + 1))
        );
        insert li;
        Test.stopTest();
        System.assertEquals(10, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(10, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
        System.assertEquals(10, [SELECT Id, LineItem__c FROM OpportunityLineItem ORDER BY LineItem__c DESC LIMIT 1].LineItem__c);
    }

    @isTest
    private static void test02_update() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry LIMIT 1];
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            UnitPrice        = pbe.UnitPrice,
            Quantity         = 5.00
        );
        insert li;
        System.assertEquals(500.00, [SELECT Id, TotalPrice FROM OpportunityLineItem].TotalPrice);
        Test.startTest();
        li.Quantity = 10.00;
        update li;
        Test.stopTest();
        System.assertEquals(1000.00, [SELECT Id, TotalPrice FROM OpportunityLineItem].TotalPrice);
    }

    @isTest
    private static void test03_delete() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        List<PricebookEntry> pbes = [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry];
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (Integer i=0; i<10; i++) {
            OpportunityLineItem li = new OpportunityLineItem(
                OpportunityId    = o.Id,
                PricebookEntryId = pbes[i].Id,
                UnitPrice        = pbes[i].UnitPrice,
                Quantity         = 10.00
            );
            lineItems.add(li);
        }
        insert lineItems;
        System.assertEquals(10, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(10, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
        Test.startTest();
        delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :o.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals(9, [SELECT COUNT() FROM OpportunityLineItem]);
        System.assertEquals(9, [SELECT Id, OpportunityLineItems__c FROM Account WHERE Id = :a.Id].OpportunityLineItems__c);
    }

    @isTest
    private static void test04_validate() {
        Account     a      = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity o      = [SELECT Id, Name FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        PricebookEntry pbe = [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry LIMIT 1];
        Test.startTest();
        OpportunityLineItem li = new OpportunityLineItem(
            OpportunityId    = o.Id,
            PricebookEntryId = pbe.Id,
            UnitPrice        = pbe.UnitPrice,
            Quantity         = 0.00
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
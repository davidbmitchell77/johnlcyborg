for (Account a : [SELECT Id, Name, (SELECT Id, Name FROM Contacts)
                    FROM Account
]) {
    System.debug(LoggingLevel.INFO, System.JSON.serializePretty(a));
}
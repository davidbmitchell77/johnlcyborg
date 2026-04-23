public with sharing class AccountsController {
    private static final Integer querySizeLimit = 200;

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        return [SELECT Id,
                       Salutation,
                       FirstName,
                       LastName,
                       Pronouns,
                       Title,
                       Email,
                       Phone,
                       MobilePhone,
                       HomePhone,
                       MailingStreet,
                       MailingCity,
                       MailingState,
                       MailingPostalCode,
                       MailingCountry,
                       OtherStreet,
                       OtherCity,
                       OtherState,
                       OtherPostalCode,
                       OtherCountry,
                       ReportsToId,
                       ReportsTo.Salutation,
                       ReportsTo.Name,
                       ReportsTo.Title,
                       ReportsTo.Email,
                       ReportsTo.Phone,
                       ReportsTo.MobilePhone,
                       ReportsTo.HomePhone,
                       AccountId,
                       Account.Name
                  FROM Contact
                 WHERE AccountId = :accountId
                  WITH USER_MODE
              ORDER BY LastName ASC, FirstName ASC
                 LIMIT :querySizeLimit
        ];
    }
}
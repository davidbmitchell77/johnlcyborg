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
                       MailingPostalCode,
                       MailingCountry,
                       ReportsTo.Salutation,
                       ReportsTo.Name,
                       ReportsTo.Title,
                       reportsTo.Email,
                       ReportsTo.Phone,
                       ReportsTo.MobilePhone,
                       ReportsTo.HomePhone
                  FROM Contact
                 WHERE AccountId = :accountId
                  WITH USER_MODE
              ORDER BY LastName ASC, FirstName ASC
                 LIMIT :querySizeLimit
        ];
    }
}
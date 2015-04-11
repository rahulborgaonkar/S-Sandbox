global class batchAccountUpdate implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        for(Account a : scope)
        {
            a.phone = '123456789';
            update a;
        }
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}
public class Sales_Commission_Detail_Extension
{
    public Sales_Commission_Detail__c scd{get;set;}
    public Sales_Commission_Plan__c scp{get;set;}
    ApexPages.StandardController cont;
    public integer displayItem{get;set;}

    public Sales_Commission_Detail_Extension(ApexPages.StandardController controller) 
    {
        displayItem = 0;
        scd = (Sales_Commission_Detail__c) controller.getRecord();
        cont = controller;
        system.debug('Sales_Commission_Detail__c - ' + scd);
        if(scd.id != null)
        {
            scd = [SELECT Id, Sales_Commission_Plan__c FROM Sales_Commission_Detail__c where id = :scd.id];
            system.debug('Sales_Commission_Detail__c - ' + scd);
        }
        scp = [SELECT Name, Id FROM Sales_Commission_Plan__c where id = :scd.Sales_Commission_Plan__c LIMIT 1];
        system.debug('Sales_Commission_Plan__c - ' + scp);
    }

    public void init()
    {
        system.debug('Boolean - ' + displayItem);
    }

    public PageReference save() 
    {
        system.debug('Inside PageReference - Plan save()');
        upsert scd;
        PageReference pr = new PageReference('/'+scp.Id);
        pr.setRedirect(true);
        return pr;
    }
}
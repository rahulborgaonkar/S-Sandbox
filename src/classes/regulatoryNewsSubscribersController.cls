public class regulatoryNewsSubscribersController 
{
    public static Boolean doclose = false;    

    public Boolean getdoClose()
    {
        system.debug('getdoClose - ' + doclose);
        return doclose;
    }

    public void setdoClose(Boolean doClos)
    {
        doclose = doclos;
        system.debug('setdoClose - ' + doclose);        
    }

    public PageReference init()
    {
        system.debug('init function');
        contact cnct = [SELECT id, Regulatory_News_Subscriber__c FROM Contact where id = :ApexPages.currentPage().getParameters().get('id')];
        if(cnct.Regulatory_News_Subscriber__c == false)
        {
            doclose = true;
        }
        return null;
    }

    public PageReference confirm()
    {
        system.debug(ApexPages.currentPage().getParameters().get('id'));
        contact cnct = [SELECT id, email, Regulatory_News_Subscriber__c FROM Contact where id = :ApexPages.currentPage().getParameters().get('id')];
        cnct.Regulatory_News_Subscriber__c = false;
        update cnct;
        doclose = true;

        OrgWideEmailAddress ir = [SELECT id, displayname, address FROM OrgWideEmailAddress WHERE Address = 'ir@synety.com'];
        EmailTemplate template = [SELECT id, subject, htmlvalue, body FROM EmailTemplate WHERE Name = 'Regulatory News Subscribers Leaving Template'];

        list<string> toemail = new list<string> ();
        toemail.add(ir.address);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(ir.id);
        mail.setTargetObjectId(cnct.id);
        mail.setToAddresses(toemail);
        mail.setTemplateID(template.id); //don't remove, commented for testing purpose

        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}, false);
        system.debug('Messaging.SendEmailResult - ' + results);

        return null;
    }
}
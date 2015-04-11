public class Sales_Commission_Plan_Extension
{
    public String Partner_Types {get;set;}
    public String Event {get;set;}
    public String SubEvent {get;set;}
    public String Frequencies {get;set;}
    public String Commissions_Types {get;set;}
    public String sales_commission_detail_id {get;set;}
    public Id detailId{get;set;}
    public Id commissionId{get;set;}
    public Boolean percentTrue{get;set;}
    public Boolean amountTrue{get;set;}
    public Boolean noOtherFields{get;set;}
    public Boolean oneTimeRendered{get;set;}
            
    public Boolean renderList {get;set;}
    
    ApexPages.StandardController cont;

    public Sales_Commission_Plan__c scp {get;set;}
    public Sales_Partner_Type__c spt {get;set;}
    public Sales_Commission_Detail__c scd {get;set;}
    public Sales_Telesales_Detail__c std {get;set;}

    public List<Sales_Commission_Detail__c> scdList {get;set;}

    public Sales_Commission_Plan_Extension(ApexPages.StandardController controller) 
    {
        system.debug('Constructor Sales_Commission_Plan_Extension');
        scp = (Sales_Commission_Plan__c) controller.getRecord();
        std = new Sales_Telesales_Detail__c();
        
        if(scp.id != null)
        {
            scp = [SELECT Name, Id, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate FROM Sales_Commission_Plan__c where id = :scp.id LIMIT 1];
        }
        cont = controller;
        scp.ownerid = Userinfo.getUserid();

        scdList = new List<Sales_Commission_Detail__c>();

        for(Sales_Commission_Detail__c s : [SELECT Commissions_Types__c, Event__c, Sub_Event__c, Frequencies__c, Partner_Types__c, Id, Name, Sales_Commission_Plan__c, Selected_Record__c, SingleEvent__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c where Sales_Commission_Plan__c = :scp.id])
        {
            scdList.add(s);
            if(s.Selected_Record__c == true)
            {
                scd = s;
            }
            if(s.SingleEvent__c == true)
            {
                oneTimeRendered = true;
            }
            else
            {
                renderList = true;
            }
        }

        scdList.sort();
/*
        if(scdList.size() > 0)
        {
            renderList = true;
        }
        else
        {
            renderList = false;
        }
*/
    }

    public PageReference save() 
    {
        system.debug('Inside PageReference - Plan save()');
        upsert scp;
        PageReference pr = new PageReference('/'+scp.Id);
        pr.setRedirect(true);
        return pr;
    }

    public void eventFunctionMethod()
    {
        spt = new Sales_Partner_Type__c();
        system.debug('In eventFunctionMethod');
        system.debug('Partner_Types - ' + Partner_Types);
        system.debug('Event - ' + Event);
        spt.Partner_Types__c = Partner_Types;
        spt.Event__c = Event;
        if(Event == '' || (Partner_Types == 'Channel Sales Partner' && (Event == 'Hardware Sales' || Event == 'Hardware Rentals')))
        {
            system.debug('Found False');
            noOtherFields = false;
        }
        else
        {
            system.debug('Found True');
            noOtherFields = true;
        }
        
        system.debug('Sales_Partner_Type__c spt - ' + spt);
    }


    public void actionFunctionMethod()
    {
        spt = new Sales_Partner_Type__c();
        system.debug('In actionFunctionMethod');
        system.debug('Partner_Types - ' + Partner_Types);
        system.debug('Frequencies - ' + Frequencies);
        system.debug('Commissions_Types - ' + Commissions_Types);
        spt.Partner_Types__c = Partner_Types;
        spt.Event__c = Event;
        spt.Sub_Event__c = SubEvent;
        spt.Frequencies__c = Frequencies;
        spt.Commissions_Types__c = Commissions_Types;
        system.debug('Sales_Partner_Type__c spt - ' + spt);
    }

    public void selectFunctionMethod()
    {
        system.debug('Inside selectFunctionMethod');
        system.debug('sales_commission_detail_id - ' + sales_commission_detail_id);
        if(scdList.size() == 1)
        {
            scdList[0].Selected_Record__c = true;
            scd = scdList[0];
        }
        else
        {
            for(Sales_Commission_Detail__c s : scdList)
            {
                if(s.id != sales_commission_detail_id)
                {
                    s.Selected_Record__c = false;
                }
                else if(s.id == sales_commission_detail_id && s.Selected_Record__c == false)
                {
                    s.Selected_Record__c = true;
                }
                else
                {
                    scd = s;
                }
            }
        }
        update scdList;
        if(scdList.size() > 0)
        {
            renderList = true;
        }
        else
        {
            renderList = false;
        }
        system.debug('Sales_Commission_Detail__c scd - ' + scd);
    }

    public void deleteRangeRecord()
    {
        system.debug('Inside deleteRangeRecord');
        system.debug('commissionId - ' + commissionId);

        List<Sales_Telesales_Detail__c> pcd = [SELECT Name, Minimum__c, Maximum__c, Amount__c, Sales_Commission_Detail__c FROM Sales_Telesales_Detail__c where id = :commissionId LIMIT 1];

        if(pcd.size() > 0)
        {
            system.debug('Sales_Telesales_Detail__c pcd - ' + pcd);
            delete pcd;
        }
    }

    public PageReference addDetail()
    {
        system.debug('In addPartners');
        List<Sales_Commission_Detail__c> lscd = new List<Sales_Commission_Detail__c>();
        system.debug('Sales_Partner_Type__c spt - ' + spt);
        system.debug('List<Sales_Commission_Detail__c> scdList - ' + scdList);

        if(spt != null)
        {
            if((spt.Partner_Types__c == 'Telesales Partner' || spt.Partner_Types__c == 'Referral Partner' || spt.Partner_Types__c == 'CRM Integrator Partner') && (spt.Sub_Event__c.contains('Monthly')))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Selected wrong Sub Event for Partner Type');
                ApexPages.addMessage(myMsg);             
            }
            else if(spt.Partner_Types__c == null || spt.Event__c ==  null || spt.Commissions_Types__c == null || spt.Frequencies__c == null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Frequency and Commission Types are Mandatory fields');
                ApexPages.addMessage(myMsg);             
            }
            else
            {
                lscd = [SELECT Commissions_Types__c, Event__c, Sub_Event__c, Frequencies__c, Partner_Types__c, Sales_Commission_Plan__c, SingleEvent__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c 
                    where Commissions_Types__c = :spt.Commissions_Types__c and Event__c = :spt.Event__c and Sub_Event__c = :spt.Sub_Event__c and Frequencies__c = :spt.Frequencies__c 
                    and Partner_Types__c = :spt.Partner_Types__c and Sales_Commission_Plan__c = :scp.id];

                system.debug('Sales_Commission_Detail__c scd.size - ' + lscd.size());

                if(lscd.size() > 0)
                {
                    system.debug('Found record scd - ' + lscd);
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Type already exists for this plan');
                    ApexPages.addMessage(myMsg);             
                }
                else
                {
                    system.debug('Add scp - ' + scp);
                    Sales_Commission_Detail__c tmp_scd = new Sales_Commission_Detail__c();
                    tmp_scd.Sales_Commission_Plan__c = scp.id;
                    tmp_scd.Event__c = spt.Event__c;
                    tmp_scd.Sub_Event__c = spt.Sub_Event__c;
                    tmp_scd.Partner_Types__c = spt.Partner_Types__c;
                    tmp_scd.Frequencies__c = spt.Frequencies__c;
                    tmp_scd.Commissions_Types__c = spt.Commissions_Types__c;
                    system.debug('tmp_scd.Event__c - ' + tmp_scd.Event__c);
                    system.debug('tmp_scd.Sub_Event__c - ' + tmp_scd.Sub_Event__c);
                                        
                    if(!((tmp_scd.Event__c == 'License Subscription' || tmp_scd.Event__c == 'Enhance Support Package') && tmp_scd.Sub_Event__c == 'Deal Size'))
                    {
                        tmp_scd.SingleEvent__c = true;
                        tmp_scd.Selected_Record__c = false;
                    }
                    lscd.clear();

                    for(Sales_Commission_Detail__c s : scdList)
                    {
                        if(s.Selected_Record__c == true)
                        {
                            lscd.add(s);
                        }
                    }
                    
                    if(lscd.size() == 0)
                    {
                        tmp_scd.Selected_Record__c = true;
                    }

                    scdList.add(tmp_scd);

                    if(scdList.size() == 1 && tmp_scd.SingleEvent__c == false)
                    {
                        tmp_scd.Selected_Record__c = true;
                    }

                    scd = tmp_scd;
                    system.debug('Sales_Commission_Detail__c scd - ' + scd);
                    upsert scdList;
                    scdList.sort();
                    system.debug('scdList - ' + scdList);
                    renderList = true;
                    if(tmp_scd.SingleEvent__c == true)
                    {
                        Pagereference saveReturn = new Pagereference('/apex/Sales_Commission_Plan_OneTime_Page?id='+scp.id+'&scdid='+tmp_scd.id);
                        saveReturn.SetRedirect(true);
                        return saveReturn ;
                    }
                    else
                    {
                        Pagereference saveReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id);
                        saveReturn.SetRedirect(true);
                        return saveReturn ;
                    }
                }
            }
        }
        else
        {
            system.debug('Found record lscd - ' + lscd);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Partner Type, Event, Sub Event, Frequency & Commission Type all must be selected');
            ApexPages.addMessage(myMsg);             
        }
        return null;
    }

    public PageReference deleteDetail()
    {
        system.debug('Inside deleteDeal');
        system.debug('detailId - ' + detailId);
        List<Sales_Commission_Detail__c> tmp_scdList = new List<Sales_Commission_Detail__c> ();

        system.debug('Before scdList.size() - ' + scdList.size());

        for(Sales_Commission_Detail__c s : scdList)
        {
            if(s.id == detailId)
            {
                delete s;
            }
            else
            {
                s.Selected_Record__c = false;
                tmp_scdList.add(s);
            }
        }

        scdList.clear();
        scdList.addAll(tmp_scdList);

        system.debug('After scdList.size() - ' + scdList.size());
        system.debug('After tmp_scdList.size() - ' + tmp_scdList.size());
        for(Sales_Commission_Detail__c s : scdList)
        {
            if(s.SingleEvent__c == false)
            {
                system.debug('scdList[0].Selected_Record__c - ' + scdList[0].Selected_Record__c);
                s.Selected_Record__c = true;
                break;
            }
        }
        update scdList;

        if(scdList.size() > 0)
        {
            renderList = true;
        }
        else
        {
            renderList = false;
        }

        Pagereference delReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id+'&sfdc.override=1');
        delReturn.SetRedirect(true);
        return delReturn;
    }

    public List<Sales_Commission_Detail__c> getOneTimeDetails()
    {
        system.debug('Inside getOneTimeDetails');
        system.debug('scdList - ' + scdList);
        List<Sales_Commission_Detail__c> pcd = new List<Sales_Commission_Detail__c> ();
        for(Sales_Commission_Detail__c c : scdList)
        {
            if(c.SingleEvent__c == true)
            {
                pcd.add(c);
            }
        }
        if(pcd.size() > 0)
        {
            oneTimeRendered = true;
        }
        else
        {
            oneTimeRendered = false;
        }
        return pcd;
    }

    public List<Sales_Commission_Detail__c> getMultipleTimeDetails()
    {
        system.debug('Inside getMultipleTimeDetails');
        system.debug('scdList - ' + scdList);
        List<Sales_Commission_Detail__c> pcd = new List<Sales_Commission_Detail__c> ();
        for(Sales_Commission_Detail__c c : scdList)
        {
            if(c.SingleEvent__c != true)
            {
                pcd.add(c);
            }
        }
        return pcd;
    }

    public void oneTimeInit()
    {
        system.debug('Inside oneTimeInit');
        system.debug('scd - ' + scd);
        ID id = apexpages.currentpage().getparameters().get('scdid');
        if(id != null)
        {
            scd = [SELECT Commissions_Types__c, Event__c, Sub_Event__c, Frequencies__c, Partner_Types__c, Id, Name, Sales_Commission_Plan__c, Selected_Record__c, SingleEvent__c, Unit_Sign__c, Value__c FROM Sales_Commission_Detail__c where id = :id];
        }
        if(scd.Sub_Event__c == 'Monthly Min Target' || scd.Sub_Event__c == 'Monthly OTE')
        {
            scd.Unit_Sign__c = 'L';
        }
        else if(scd.Event__c == 'Professional Service' || scd.Event__c == 'Hardware Sales & Rentals' || scd.Event__c == 'Multi Year Contract (Licenses / Support)')
        {
            scd.Unit_Sign__c = '%';
        }
        else
        {
            scd.Unit_Sign__c = '£';
        }
    }

    public void rangeInit()
    {
        system.debug('Inside rangeInit');
        system.debug('scd - ' + scd);
        system.debug('commissionId - ' + commissionId);
        ID id = apexpages.currentpage().getparameters().get('commid');
        if(id != null)
        {
            std = [SELECT Name, Minimum__c, Maximum__c, Amount__c, Percentage__c, Sales_Commission_Detail__c FROM Sales_Telesales_Detail__c where id = :id];
        }

        if(scd != null)
        {
            if(scd.Partner_Types__c == 'CRM Integrator Partner')
            {
                system.debug('Yes');
                percentTrue = true;
                amountTrue = false;
            }
            else
            {
                system.debug('No');
                amountTrue = true;
                percentTrue = false;
            }
        }
    }

    public PageReference saveTelesalesDetails()
    {
        system.debug('Inside getCommissionDetails');
        if(std.Sales_Commission_Detail__c == null)
        {
            std.Sales_Commission_Detail__c = scd.id;
        }
        system.debug('Sales_Telesales_Detail__c std - ' + std);
        upsert std;
        Pagereference saveReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id+'&sfdc.override=1');
        saveReturn.SetRedirect(true);
        return saveReturn;
    }

    public PageReference cancelTelesalesDetails()
    {
        system.debug('Inside getCommissionDetails');
        Pagereference cancelReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id+'&sfdc.override=1');
        cancelReturn.SetRedirect(true);
        return cancelReturn;
    }

    public PageReference saveOneTime()
    {
        system.debug('Inside getCommissionDetails');
        upsert scd;
        Pagereference saveReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id+'&sfdc.override=1');
        saveReturn.SetRedirect(true);
        return saveReturn;
    }


    public PageReference cancelOneTime()
    {
        system.debug('Inside getCommissionDetails');
        Pagereference cancelReturn = new Pagereference('/apex/Sales_Commission_Plan_View?id='+scp.id+'&sfdc.override=1');
        cancelReturn.SetRedirect(true);
        return cancelReturn;
    }


    public void doNothing()
    {
        system.debug('Inside doNothing');
    }

    public List<Sales_Telesales_Detail__c> getCommissionDetails()
    {
        system.debug('Inside getCommissionDetails');
        system.debug('scdList - ' + scdList);
        Sales_Commission_Detail__c tmp_scd;
        List<Sales_Telesales_Detail__c> pcd = new List<Sales_Telesales_Detail__c> ();
            
        for(Sales_Commission_Detail__c s : scdList)
        {
            if(s.Selected_Record__c == true)
            {
                scd = s;
            }
        }
        system.debug('Sales_Commission_Detail__c scd - ' + scd);
        if(scd != null)
        {
            if(scd.Partner_Types__c == 'CRM Integrator Partner')
            {
                percentTrue = true;
                amountTrue = false;
            }
            else
            {
                amountTrue = true;
                percentTrue = false;
            }

            pcd = [SELECT Name, Minimum__c, Maximum__c, Amount__c, Percentage__c, Sales_Commission_Detail__c, Sales_Commission_Detail__r.Event__c FROM Sales_Telesales_Detail__c where Sales_Commission_Detail__c = :scd.id ORDER BY Minimum__c];
            system.debug('Sales_Telesales_Detail__c pcd - ' + pcd);
        }

        return pcd;
    }
}
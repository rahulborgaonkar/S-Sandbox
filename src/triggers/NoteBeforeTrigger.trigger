trigger NoteBeforeTrigger on Note (before insert, before update, before delete) 
{
    ID currUserId = UserInfo.getUserId();
    User currUser = [SELECT Id, UserRoleId, UserType, Username FROM User WHERE Id = :currUserId];
    UserRole currRole = [SELECT Id, Name, PortalAccountId FROM UserRole WHERE id = :currUser.UserRoleId];

    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    Map<String,String> keyPrefixMap = new Map<String,String>{};
    Set<String> keyPrefixSet = gd.keySet();

    for(String sObj : keyPrefixSet)
    {
        Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
        String tempName = r.getName();
        String tempPrefix = r.getKeyPrefix();
        System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
        keyPrefixMap.put(tempPrefix,tempName);
    }

    if(currRole.name == 'QA Engineer' && (Trigger.isInsert || Trigger.isUpdate))
    {
        for(Note nt : Trigger.new)
        {
            String tPrefix = nt.ParentId;
            tPrefix = tPrefix.subString(0,3);
            string objectName = keyPrefixMap.get(tPrefix);

            if(objectName == 'Synety_Plugin__c')
            {
                system.debug('Wrong User to insert/update/delete');
                nt.addError('You cannot Insert/Update Note File');
            }
        }
    }

    if(currRole.name == 'QA Engineer' && Trigger.isDelete)
    {
        for(Note nt : Trigger.old)
        {
            String tPrefix = nt.ParentId;
            tPrefix = tPrefix.subString(0,3);
            string objectName = keyPrefixMap.get(tPrefix);

            if(objectName == 'Synety_Plugin__c')
            {
                system.debug('Wrong User to insert/update/delete');
                nt.addError('You cannot Delete Note File');
            }
        }
    }
}
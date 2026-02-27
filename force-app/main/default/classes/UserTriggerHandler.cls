public with sharing class UserTriggerHandler {
    private final TriggerOperation operationType;
    private final String           apexClassName;
    private final String           groupId;
    private final String           sysAdminId;

    public UserTriggerHandler(TriggerOperation to) {
        this.operationType = to;
        this.apexClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
        this.groupId       = [SELECT Id FROM Group WHERE DeveloperName = 'Admins' LIMIT 1].Id;
        this.sysAdminId    = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    }

    public void run(List<User> oldUsers, List<User> newUsers, Map<Id,User> oldMap, Map<Id,User> newMap) {
        switch on this.operationType {
            when BEFORE_INSERT {

            }
            when BEFORE_UPDATE {

            }
            when AFTER_INSERT {
                updateGroupMembership(null, newUsers, null, newMap);
            }
            when AFTER_UPDATE {
                updateGroupMembership(oldUsers, newUsers, oldMap, newMap);
            }
        }
    }

    public Boolean isValid(List<User> users) {
        Boolean result = true;
        if (users != null) {
            for(User u : users) {
                if (String.isBlank(u.LastName)) {
                    u.LastName.addError(System.Label.USER_LAST_NAME_IS_REQUIRED);
                    result = false;
                }
            }
        }
        return result;
    }

    private void updateGroupMembership(List<User> oldUsers, List<User> newUsers, Map<Id,User> oldMap, Map<Id,User> newMap) {
        List<GroupMember> addMembers = new List<GroupMember>();
        List<GroupMember> removeMembers = new List<GroupMember>();

        Map<Id,GroupMember> members = new Map<Id,GroupMember>();
        for (GroupMember m : [SELECT Id, GroupId, UserOrGroupId
                                FROM GroupMember
                               WHERE GroupId = :this.groupId
                                 AND UserOrGroupId IN :newMap.keySet()
                                WITH SYSTEM_MODE
        ]) {
            members.put(m.UserOrGroupId, m);
        }

        for (User u : newUsers) {
            Boolean addToGroup = false;
            Boolean removeFromGroup = false;
            switch on this.operationType {
                when AFTER_INSERT {
                    if (u.ProfileId == this.sysAdminId) {
                        addToGroup = true;
                    }
                }
                when AFTER_UPDATE {
                    User oldUser = oldMap.get(u.Id);
                    User newUser = newMap.get(u.Id);
                    if (oldUser.ProfileId != newUser.ProfileId) {
                        if (oldUser.ProfileId == this.sysAdminId) {
                             removeFromGroup = true;
                        }
                        if (newUser.profileId == this.sysAdminId) {
                            addToGroup = true;
                        }
                    }
                    if (oldUser.IsActive != newUser.IsActive) {
                        if (u.ProfileId == this.sysAdminId) {
                            if (u.IsActive == false) {
                                removeFromGroup = true;
                            }
                            else {
                                addToGroup = true;
                            }
                        }
                    }
                }
            }
            if (removeFromGroup == true) { removeMembers.add(new GroupMember(Id=members.get(u.Id).Id));               } else
            if (addToGroup      == true) { addMembers.add(new GroupMember(GroupId=this.groupId, UserOrGroupId=u.Id)); }
        }

        if (!addMembers.isEmpty()) {
            for (Database.SaveResult sr : Database.insert(addMembers, false)) {
                if (!sr.isSuccess()) { for (Database.Error e : sr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.apexClassName + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }

        if (!removeMembers.isEmpty()) {
            for (Database.DeleteResult dr : Database.delete(removeMembers, false)) {
                if (!dr.isSuccess()) { for (Database.Error e : dr.getErrors()) { System.debug(LoggingLevel.ERROR, (this.apexClassName + ': ' + e.getStatusCode() + '|' + e.getMessage())); } }
            }
        }
    }
}
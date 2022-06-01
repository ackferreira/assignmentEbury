Group reviewersGroup = [SELECT Id FROM Group WHERE DeveloperName = 'TradeReviewers' LIMIT 1];
User adminUser = [SELECT Id FROM User WHERE profile.name = 'System Administrator'];
GroupMember member = new GroupMember(
    UserOrGroupId = adminUser.Id,
    GroupId = reviewersGroup.Id
);
insert member;
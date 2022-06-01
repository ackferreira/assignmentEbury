Group reviewersGroup = [SELECT Id FROM Group WHERE DeveloperName = 'TradeReviewers' LIMIT 1];
User adminUser = [SELECT Id FROM User WHERE Name = 'User User' LIMIT 1];
GroupMember member = new GroupMember(
    UserOrGroupId = adminUser.Id,
    GroupId = reviewersGroup.Id
);
insert member;
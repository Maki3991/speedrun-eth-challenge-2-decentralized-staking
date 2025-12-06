### Speedrun ETH Challenge #1
Finished on 2025/12/06

比较难，光是在checkpoint1的代码就卡了一上午，最后用的Gemini一步一步带我把代码搭建起来的

- `address(this)` 得到的是该合约在deploy后的链上地址
- `(bool success, ) = msg.sender.call{ value: amount }("");` .call()本来是用来调用其他合约内的函数的，“()”内写具体函数，返回两个值，第一个是bool，代表操作成功/失败，第二个是被调用合约的返回信息，此处留空。“{}”代表转账，
- 发送ETH的统一逻辑
-   先用mapping，把数据清空
-   转账
-   require检查操作是否成功，若失败可自动Revert
-   function withdraw() public notCompleted {
    require(openForWithdraw, "You can't withdraw!");

    uint256 amount = balances[msg.sender];

    require(amount > 0, "You don't have ETH in it!");

    balances[msg.sender] = 0;

    (bool success, ) = msg.sender.call{ value: amount }("");
    require(success, "Transfer failed");

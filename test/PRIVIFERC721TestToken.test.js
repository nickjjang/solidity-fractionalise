const PRIVIFERC721TestToken = artifacts.require("PRIVIFERC721TestToken");

contract("PRIVIFERC721TestToken", (accounts) => {
  let token;
  const tokenIds = [
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174610",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174611",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174612",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174613",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174614",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174615",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174616",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174617",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174618",
    "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174619",
  ];

  before(async () => {
    token = await PRIVIFERC721TestToken.deployed();
    for (let i = 0; i < tokenIds.length; i++) {
      await token.mint(accounts[1], tokenIds[i], 100);
    }
  });

  describe("PRIVIFERC721", () => {
    it("mint", async () => {
      await token.approve(accounts[2], tokenIds[0], 50, {
        from: accounts[1],
      });
      await token.transfer(accounts[2], tokenIds[0], 50, {
        from: accounts[1],
      });
      await token.transfer(accounts[3], tokenIds[0], 50, {
        from: accounts[1],
      });
      assert.equal((await token.ownersOf(tokenIds[0])).length, 2);
      assert.equal(await token.balanceOf(accounts[2], tokenIds[0]), 50);
    });
  });
});

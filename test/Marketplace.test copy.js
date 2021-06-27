// const Marketplace = artifacts.require("Marketplace");

// const PRIVIERC20TestToken = artifacts.require("PRIVIERC20TestToken");
// const PRIVIOfferTestToken = artifacts.require("PRIVIOfferTestToken");
// const FERC721 = artifacts.require("FERC721");

// contract("TokenExchange", (accounts) => {
//   let marketplaceContract;
//   let ofertokenContract;
//   let fundingtokenContract;


//   const tokenIds = [
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174610",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174611",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174612",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174613",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174614",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174615",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174616",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174617",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174618",
//     "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174619",
//   ];

//   before(async () => {
//     marketplaceContract = await Marketplace.new({
//       from: accounts[0],
//     });
//     for (let i = 0; i < tokenIds.length; i++) {
//       await mint(accounts[1], tokenIds[i], 100);
//     }

//     // await mint(accounts[0], "0x222222229bd51a8f1fd5a5f74e4a256513210caf2ade63cd25c7e4c654174617");
//   });

//   describe("Marketplace", () => {
//     it("not working if balance is not enough", async () => {});
//   });
// });

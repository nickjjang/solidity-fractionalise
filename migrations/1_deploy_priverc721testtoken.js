const PRIVIFERC721TestToken = artifacts.require("PRIVIFERC721TestToken");

module.exports = function (deployer) {
  deployer.deploy(PRIVIFERC721TestToken);
};

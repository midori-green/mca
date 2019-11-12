var point_system = artifacts.require("point_system");
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(point_system);
};
var abi = require("ethereumjs-abi");

const EternalStorageProxy = artifacts.require("./EternalStorageProxy.sol");
const ElectricityContract_v1 = artifacts.require("./ElectricityContract_v1.sol");
const ElectricityContract_v2 = artifacts.require("./ElectricityContract_v2.sol");

module.exports = function(deployer, network, accounts) {

    const rate = web3.toWei('0.01', 'ether');

    return deployer
        .then(() => {
            return deployer.deploy(EternalStorageProxy);
        })
        .then(() => {
            return deployer.deploy(ElectricityContract_v1);
        })
        .then(() => {
            return deployer.deploy(ElectricityContract_v2);
        })
        .then (() => {
            return EternalStorageProxy.deployed();
        }).then ((instance) => {

            let data = "0x" + abi.simpleEncode("initialize(uint)", rate).toString("hex");
            //["0xfe","0x4b","0x84","0xdf","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x00","0x23","0x86","0xf2","0x6f","0xc1","0x00","0x00"]
            console.log('Data: ', data);
            return instance.upgradeToAndCall('0', ElectricityContract_v1.address, data);
        });
};


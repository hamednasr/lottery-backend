const { network } = require("hardhat")

module.export = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const lottery = await deploy("lottery", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockCofirmations || 1,
    })
}

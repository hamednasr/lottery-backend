const { network, ethers } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config.js")
const { verify } = require("../utils/verify.js")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const vrfCoordinatorV2 = networkConfig[chainId]["vrfCoordinatorV2"]
    const keyHash = networkConfig[chainId]["keyHash"]
    const minFee = ethers.utils.parseEther("0.01")
    const subscriptionId = 6637
    const callbackGasLimit = 1e5

    const lottery = await deploy("lottery", {
        from: deployer,
        args: [vrfCoordinatorV2, minFee, keyHash, subscriptionId, callbackGasLimit],
        log: true,
        waitConfirmations: network.config.blockCofirmations,
    })

    if (process.env.ETHERSCAN_API_KEY) {
        log("The contrcat is being verified on Rinkeby network.....")
        await verify(lottery.address, [
            vrfCoordinatorV2,
            minFee,
            keyHash,
            subscriptionId,
            callbackGasLimit,
        ])
        log("verified!")
    }

    log("============================================================")
}

module.exports.tags = ["all", "lottery"]

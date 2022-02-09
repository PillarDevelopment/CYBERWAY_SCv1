require("solidity-coverage");
require("@nomiclabs/hardhat-waffle");
require('dotenv').config({path:__dirname+'/process.env'})
require('hardhat-deploy');
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-truffle5");

const fs = require("fs");

const {PROD_PRIVATE_KEY, TEST_PRIVATE_KEY, ETHERSCAN_API_KEY} = process.env;

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000000,
            },
        },
    },
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545"
        },
        bsctestnet: {
            url: "https://data-seed-prebsc-1-s1.binance.org:8545",
            accounts: [`${TEST_PRIVATE_KEY}`],
            chainId: 97,
            saveDeployments: true,
            gasMultiplier: 2
        },
        bsc: {
            url: 'https://bsc-dataseed.binance.org/',
            accounts: [`${PROD_PRIVATE_KEY}`],
            chainId: 56,
            live: true,
            saveDeployments: true,
            tags: ["staging"],
            gasMultiplier: 2
        }
    },
    gasReporter: {
        enable: true,
        currency: 'USD',
        showTimeSpent: true,
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY
    },
};



function getSortedFiles(dependenciesGraph) {
  const tsort = require("tsort")
  const graph = tsort()

  const filesMap = {}
  const resolvedFiles = dependenciesGraph.getResolvedFiles()
  resolvedFiles.forEach((f) => (filesMap[f.sourceName] = f))

  for (const [from, deps] of dependenciesGraph.entries()) {
    for (const to of deps) {
      graph.add(to.sourceName, from.sourceName)
    }
  }

  const topologicalSortedNames = graph.sort()

  // If an entry has no dependency it won't be included in the graph, so we
  // add them and then dedup the array
  const withEntries = topologicalSortedNames.concat(resolvedFiles.map((f) => f.sourceName))

  const sortedNames = [...new Set(withEntries)]
  return sortedNames.map((n) => filesMap[n])
}

function getFileWithoutImports(resolvedFile) {
  const IMPORT_SOLIDITY_REGEX = /^\s*import(\s+)[\s\S]*?;\s*$/gm

  return resolvedFile.content.rawContent.replace(IMPORT_SOLIDITY_REGEX, "").trim()
}

subtask("flat:get-flattened-sources", "Returns all contracts and their dependencies flattened")
    .addOptionalParam("files", undefined, undefined, types.any)
    .addOptionalParam("output", undefined, undefined, types.string)
    .setAction(async ({ files, output }, { run }) => {
      const dependencyGraph = await run("flat:get-dependency-graph", { files })
      console.log(dependencyGraph)

      let flattened = ""

      if (dependencyGraph.getResolvedFiles().length === 0) {
        return flattened
      }

      const sortedFiles = getSortedFiles(dependencyGraph)

      let isFirst = true
      for (const file of sortedFiles) {
        if (!isFirst) {
          flattened += "\n"
        }
        flattened += `// File ${file.getVersionedName()}\n`
        flattened += `${getFileWithoutImports(file)}\n`

        isFirst = false
      }

      // Remove every line started with "// SPDX-License-Identifier:"
      flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:")

      flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`

      // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
      flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0))
      // Remove every line started with "pragma abicoder v2;" except the first one
      flattened = flattened.replace(/pragma abicoder v2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0))
      // Remove every line started with "pragma solidity ****" except the first one
      flattened = flattened.replace(/pragma solidity .*$\n/gm, ((i) => (m) => (!i++ ? m : ""))(0))


      flattened = flattened.trim()
      if (output) {
        console.log("Writing to", output)
        fs.writeFileSync(output, flattened)
        return ""
      }
      return flattened
    })

subtask("flat:get-dependency-graph")
    .addOptionalParam("files", undefined, undefined, types.any)
    .setAction(async ({ files }, { run }) => {
      const sourcePaths = files === undefined ? await run("compile:solidity:get-source-paths") : files.map((f) => fs.realpathSync(f))

      const sourceNames = await run("compile:solidity:get-source-names", {
        sourcePaths,
      })

      const dependencyGraph = await run("compile:solidity:get-dependency-graph", { sourceNames })

      return dependencyGraph
    })

task("flat", "Flattens and prints contracts and their dependencies")
    .addOptionalVariadicPositionalParam("files", "The files to flattener", undefined, types.inputFile)
    .addOptionalParam("output", "Specify the output file", undefined, types.string)
    .setAction(async ({ files, output }, { run }) => {
      console.log(
          await run("flat:get-flattened-sources", {
            files,
            output,
          })
      )
    })

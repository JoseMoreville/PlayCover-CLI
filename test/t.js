const playcover = require("playcover-cli")

async function main() {
  console.log(await playcover.sideload("/Users/hades/Downloads/Arknights.ipa"))
}

main()
const pinataSDK = require('@pinata/sdk');
import * as fs from 'fs';

async function main() {
  // Set your Pinata API key and secret
  const apiKey = 'f96679af700898b661ff';
  const apiSecret =
    'd40a914cd6c374fa64ce474d791fc82162d5102a2e3352ea830c6325443a3f3d';

  const pinata = new pinataSDK(apiKey, apiSecret);

  // Path to the folder that contains the files
  const folderPath =
    '/Users/ammonwerner/GitHub/ccc-contracts/DropMeFiles_L3oWd';

  // Array to store the file names
  const fileNames: string[] = [];

  // Read the contents of the folder
  const files = fs.readdirSync(folderPath);

  // remove the files before file named "142-Wrapping Paper-None-PonPon-Conemas.png"
  //   files.splice(0, 48);

  // Iterate through the files and store their names in the array
  for (const file of files) {
    // Read the image file and convert it to a buffer
    const filename = `/Users/ammonwerner/GitHub/ccc-contracts/DropMeFiles_L3oWd/${file}`;
    console.log(filename);
    const readableStreamForFile = fs.createReadStream(filename);

    //   console.log(readableStreamForFile);

    const options = {
      pinataMetadata: {
        name: file,
      },
      pinataOptions: {
        cidVersion: 0,
      },
    };

    // Upload the image to IPFS and store the CID in a new file
    await pinata
      .pinFileToIPFS(readableStreamForFile, options)
      .then((result) => {
        //   console.log(result);
        const cid = result.IpfsHash;
        console.log(`Image CID: ${cid}`);
        // parse through the file name until the first - is found
        // then add the file name to the array
        const tokenId = file.split('-')[0];
        const coneColor = file.split('-')[1];
        const coneOrnament = file.split('-')[2];
        const coneTopper = file.split('-')[3];
        const background = file.split('-')[4];
        // put the properties into an 'attributes' array
        const attributes = [
          {
            trait_type: 'Cone Color',
            value: coneColor,
          },
          {
            trait_type: 'Cone Ornament',
            value: coneOrnament,
          },
          {
            trait_type: 'Cone Topper',
            value: coneTopper,
          },
          {
            trait_type: 'Background',
            value: background,
          },
        ];

        // create a json object with the properties
        const json = {
          image: `ipfs://${cid}`,
          attributes: attributes,
        };

        // create a file named after the tokenId
        fs.writeFileSync(
          `/Users/ammonwerner/GitHub/ccc-contracts/token-json/${tokenId}.json`,
          JSON.stringify(json)
        );
      });
  }
}

// run the main function
main();

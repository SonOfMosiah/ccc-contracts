const fs = require('fs');

// Path to the folder that contains the files
const folderPath = '/Users/ammonwerner/GitHub/ccc-contracts/token-json';

// Array to store the file names
const fileNames: string[] = [];

// Read the contents of the folder
const files = fs.readdirSync(folderPath);

for (const file of files) {
  const filename = `/Users/ammonwerner/GitHub/ccc-contracts/token-json/${file}`;

  // Read in the JSON file
  let data = JSON.parse(fs.readFileSync(filename));

  data.tokenId = file;
  data.description = 'Cute Coner #' + file;
  data.name = 'Cute Coner #' + file;

  // Write the modified data back to the file
  fs.writeFileSync(filename, JSON.stringify(data));
}

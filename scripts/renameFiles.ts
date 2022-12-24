import glob from 'glob';
import fs from 'fs';

const folderPath = '/Users/ammonwerner/GitHub/ccc-contracts/token-json';
const filePattern = `${folderPath}/*.json`;

glob(filePattern, (error, filePaths) => {
  if (error) {
    console.error(error);
  } else {
    // Process the list of files
    filePaths.forEach((filePath) => {
      // Remove '.json' from the end of the file name
      const newFilePath = filePath.replace('.json', '');

      // Rename the file
      fs.renameSync(filePath, newFilePath);
    });
  }
});

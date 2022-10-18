const process = require('process');
const path = require('path');
const { promisify } = require('util');
const { execFile } = require('child_process');
const {fileURLToPath} = require('url');
//import process from 'node:process';
//import path from 'node:path';
//import { promisify } from 'node:util';
//import { execFile } from 'node:child_process';
//const dir = path.dirname(fileURLToPath(import.meta.url));


const execFileP = promisify(execFile);
const binary = path.join(__dirname, "/PlayCoverCLI/PlayCoverCLI");


exports.sideload = async (applicationPath) => {
  if (process.platform !== 'darwin') {
		throw new Error('macOS only');
	}
  const { stdout } = await execFileP(binary, [applicationPath]);
  return stdout;
}
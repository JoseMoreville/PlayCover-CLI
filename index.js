import process from 'node:process';
import path from 'node:path';
import { promisify } from 'node:util';
import { execFile } from 'node:child_process';
import { accessSync, constants } from "fs";


const __dirname = path.dirname(fileURLToPath(import.meta.url));
const execFileP = promisify(execFile);
const binary = path.join(__dirname, "/PlayCoverCLI/PlayCoverCLI");


exports.useSideload = async (applicationPath) => {
  if (process.platform !== 'darwin') {
		throw new Error('macOS only');
	}
  const { stdout } = await execFileP(binary, [applicationPath]);
  return stdout;
}
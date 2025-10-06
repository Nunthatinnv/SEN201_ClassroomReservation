/*
	File: init.js
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
	Description: Responsible for connecting to the SQLite database.
	Date: 2025-10-06

	License: GNU General Public License Version 3.0
*/

import 
{
	DatabaseSync
} from 'node:sqlite';

import 'dotenv/config';

const db = new DatabaseSync(process.env.DB_PATH);

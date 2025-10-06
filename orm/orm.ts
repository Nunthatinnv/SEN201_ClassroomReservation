/*
	File: orm.js
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
	Description: Responsible for connecting to the SQLite database.
	Date: 2025-10-06

	License: GNU General Public License Version 3.0
*/

import db from './init.js';

class ORM {
	constructor(connection) {
		this.connection = connection;
	}

	define(name, attributes) {
		this[name] = {
			name: name,
			attributes: attributes
		}
	}

	// SELECT
	async function select(model, options=[]) {
		const attributes = options.attributes || Object.keys(model.attributes);
		const where = options.where ? `WHERE ${options.where}` : '';
		const query = `SELECT ${attributes.join(', ')} FROM ${model.name} ${where}`;
		const result = await this.connection.exec(query);
		return result.rows;
	}

	// INSERT
	async function insert(model, data) {
		const attributes = Object.keys(data);
		const values = attributes.map(attribute => `'${data[attribute]}'`);
		const query = `INSERT INTO ${model.name} (${attributes.join(', ')}) VALUES (${values.join(', ')})`;
		await this.connection.exec(query);
	}

	// UPDATE
	async function update(model, data, options = {}) {
	    const attributes = Object.keys(data);
	    const values = attributes.map(attribute => `${attribute} = '${data[attribute]}'`);
	    const where = options.where ? `WHERE ${options.where}` : '';
	    const query = `UPDATE ${model.name} SET ${values.join(', ')} ${where}`;
	    await this.connection.exec(query);
	}
	
	  // DELETE
	async function delete(model, options = {}) {
	    const where = options.where ? `WHERE ${options.where}` : '';
	    const query = `DELETE FROM ${model.name} ${where}`;
	    await this.connection.exec(query);
	}
}

module.exports = ORM;

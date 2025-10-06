/*
	File: index.js
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
	Description: Main Project File
	Date: 2025-10-07

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from '../generated/prisma';

const prisma = new PrismaClient()

async function main() {
    /*
        These are demonstrations of the CRUD operations in Prisma ORM.
    */

    // CREATE

    const new_reservation = await prisma.reservation.create({
        data: {
            Reservation_id: 1,
            Room_id: 'thisisanexampleid',
            Time_start: "something something something",
            Time_end: "something something something"
        }
    })
    console.log(new_reservation);

    // READ

    const rooms = await prisma.room.findMany()
    console.log(rooms);

    // UPDATE
    
    const update_reservation = await prisma.reservation.update({
        where: {
            Reservation_id: 1
        },
        data: {
            Time_end: "thisisanexampletimestamp"
        }
    })

    // DELETE

    const delete_reservation = await prisma.reservation.delete({
        where: {
            Reservation_id: 1,
        },
    })

}

main()
    .then(async () => {
        await prisma.$disconnect()
    })
    .catch(async (e) => {
        console.error(e)
        await prisma.$disconnect()
        
    })
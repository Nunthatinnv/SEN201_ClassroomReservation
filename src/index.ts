/*
	File: index.js
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
	Description: Main Project File
	Date: 2025-10-07

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient()

async function main() {
    /*
        These are demonstrations of the CRUD operations in Prisma ORM.
    */

    // CREATE

    const new_reservation = await prisma.reservation.create({
        data: {
            reservationId: 1,
            roomId: 'thisisanexampleid',
            timeStart: "something something something",
            timeEnd: "something something something"
        }
    })
    console.log(new_reservation);

    // READ

    const rooms = await prisma.room.findMany()
    console.log(rooms);

    // UPDATE
    
    const update_reservation = await prisma.reservation.update({
        where: {
            reservationId: 1
        },
        data: {
            timeEnd: "thisisanexampletimestamp"
        }
    })

    // DELETE

    const delete_reservation = await prisma.reservation.delete({
        where: {
            reservationId: 1,
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
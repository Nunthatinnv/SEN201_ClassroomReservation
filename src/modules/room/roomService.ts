/*
	File: roomService.ts
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
    Edited by: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Room CRUD & businss logic
	Lasted Modify: 2025-10-14 22.03

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from "@prisma/client";
import type { Room, Reservation } from "@prisma/client";

const prisma = new PrismaClient();

// ----- ROOM CRUD -----

// add a room to database
export async function createRoom(data: { 
    roomId: string; 
    name: string | null; 
    capacity: number; 
    equipments: string | null;
}): Promise<
    { success: true; room: Room } | { success: false; error: any }
> {
        console.log('createRoom called with:', data);
    try {
        const result = await prisma.room.create({ data });
            console.log('Room created:', result);
        return { 
            success: true, 
            room: result 
        };
    } catch (error) {
        console.error('Error creating room:', error);
        return { 
            success: false, 
            error 
        };
    }
}

// fetch all rooms
export async function getAllRooms(): Promise<
    { success: true; rooms: Room[] } | { success: false; error: any }
> {
        console.log('getAllRooms called');
    try {
        const result = await prisma.room.findMany();
            console.log('Rooms fetched:', result);
        return { success: true, rooms: result };
    } catch (error) {
        console.error('Error fetching all rooms:', error);
        return { success: false, error };
    }
}

// get a room by roomId
export async function getRoomById(roomId: string): Promise<
    { success: true; room: Room | null } | { success: false; error: any }
> {
        console.log('getRoomById called with roomId:', roomId);
    try {
        const result = await prisma.room.findUnique({ where: { roomId } });
            console.log('Room fetched:', result);
        return { success: true, room: result };
    } catch (error) {
        console.error('Error fetching room by ID: ', roomId , error);
        return { success: false, error };
    }
}

// update a existing room by roomId
export async function updateRoom(
    roomId: string, 
    data: { 
        name?: string; 
        capacity?: number; 
        equipments?: string 
    }
): Promise<
    { success: true; room: Room } | { success: false; error: any }
> {
        console.log('updateRoom called with roomId:', roomId, 'data:', data);
    try {
        const result = await prisma.room.update({ where: { roomId }, data });
            console.log('Room updated:', result);
        return { success: true, room: result };
    } catch (error) {
        console.error('Error updating room:', error);
        return { success: false, error };
    }
}

// delete a existing room by roomId
export async function deleteRoom(roomId: string): Promise<
    { success: true; room: Room } | { success: false; error: any }
> {
        console.log('deleteRoom called with roomId:', roomId);
    try {
        const result = await prisma.room.delete({ where: { roomId } });
            console.log('Room deleted:', result);
        return { 
            success: true, 
            room: result 
        };
    } catch (error) {
        console.error('Error deleting room:', error);
        return { 
            success: false, 
            error 
        };
    }
}


// Example usage
async function main() {
    // // Room CRUD
    // const room = await createRoom({ roomId: "roomA", name: "Room A", capacity: 30 });
    // console.log("Created room:", room);

    // const rooms = await getRooms();
    // console.log("All rooms:", rooms);

    // const updatedRoom = await updateRoom("roomA", { name: "Room Alpha", capacity: 35 });
    // console.log("Updated room:", updatedRoom);

    // // Reservation CRUD
    // const reservation = await createReservation({ roomId: "roomA", timeStart: new Date("2025-10-15T09:00:00Z"), timeEnd: new Date("2025-10-15T10:00:00Z"), competency: "Math" });
    // console.log("Created reservation:", reservation);

    // const reservations = await getReservations();
    // console.log("All reservations:", reservations);

    // const updatedReservation = await updateReservation(reservation.reservationId, { timeEnd: new Date("2025-10-15T11:00:00Z"), competency: "Physics" });
    // console.log("Updated reservation:", updatedReservation);

    // // Clean up
    // await deleteReservation(reservation.reservationId);
    // await deleteRoom("roomA");
}

main()
    .then(async () => {
        await prisma.$disconnect();
    })
    .catch(async (e) => {
        console.error(e)
        await prisma.$disconnect()
        
    })
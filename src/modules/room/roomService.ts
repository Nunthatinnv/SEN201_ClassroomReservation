/*
	File: roomService.ts
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
    Edited by: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Room CRUD & businss logic
	Lasted Modify: 2025-10-14 22.03

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from "@prisma/client";
import type { Room } from "@prisma/client";
import { generateWeeklySlots } from "../reservation/reservationController"
import { getReservationsByTimeRange } from "../reservation/reservationService"

const prisma = new PrismaClient();

// ---------- ROOM CRUD ----------

// ---------- ROOM Create ----------

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



// ---------- ROOM Read ----------

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


export async function getRecommendedRooms(
    timeStart: Date,
    timeEnd: Date,
    rep: number,
    capacity: number
): Promise<{ success: true; rooms: Room[] } | { success: false; error: any }> {
    console.log('getRecommendedRooms called with:', { timeStart, timeEnd, capacity });
    try {
        // Generate all weekly time slots
        const timeSlots = generateWeeklySlots(timeStart, timeEnd, rep);
        
        // First, get all rooms that can accommodate the number of students
        const suitableRooms = await prisma.room.findMany({
        where: {
            capacity: {
            gte: capacity,
            },
        },
        });
        
        if (suitableRooms.length === 0) {
        return { success: true, rooms: [] }; // No rooms found with sufficient capacity
        }
        
        const bookedRoomIds = new Set<string>();

        for (const slot of timeSlots) {
        const result = await getReservationsByTimeRange(null, slot.timeStart, slot.timeEnd);
        
        if (!result.success) {
            return { success: false, error: result.error };
        }
        
        // Add all room IDs from overlapping reservations to the set
        result.reservations.forEach(reservation => {
            bookedRoomIds.add(reservation.roomId);
        });
        }
        
        // Filter suitable rooms to exclude those that have ANY overlap with the time slots
        const availableRooms = suitableRooms.filter((room: { roomId: any; }) => !bookedRoomIds.has(room.roomId));
        
        
        console.log('Recommended rooms:', availableRooms);
        return { success: true, rooms: availableRooms };
    } catch (error) {
        console.error('Error getting recommended rooms:', error);
        return { success: false, error };
    }
}


// ---------- ROOM Update ----------

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



// ---------- ROOM Delete ----------

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
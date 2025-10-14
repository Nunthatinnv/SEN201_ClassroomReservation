/*
	File: reservationService.ts
	Author: Win - Thanawin Pattanaphol (tpattan@cmkl.ac.th)
    Edited by: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Reservation CRUD & businss logic
	Lasted Modify: 2025-10-14 23.08

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from "@prisma/client";
import type { Reservation } from "@prisma/client";
import type { SlotData } from "../types";

const prisma = new PrismaClient();

// ----- RESERVATION CRUD -----

// create reservations with slots data
export async function createReservationBySlotData(slotData: SlotData[]): Promise<
    { success: true; created: number } | { success: false; error: any }
> {
    console.log('createReservation called with:', slotData);
    try {
        const result = await prisma.reservation.createMany({
            data: slotData,
        });
        console.log('Reservation created:', result);
        return { success: true, created: result.count };
    } catch (error) {
        console.error('Error creating reservation:', error);
        return { success: false, error };
    }
}

// get a group of reservations by seriesId 
export async function getReservationsBySeriesId(seriesId: string): Promise<
    { success: true; reservations: Reservation[] } | { success: false; error: any }
> {
        console.log('getReservationsBySeriesId called with seriesId:', seriesId);
    try {
        const result = await prisma.reservation.findMany({
            where: {
                seriesId: seriesId
            }
        });
            console.log('Reservations fetched:', result);
        return { 
            success: true, 
            reservations: result 
        };
    } catch (error) {
        console.error('Error fetching reservations by series ID:', error);
        return { 
            success: false, 
            error 
        };
    }
}


export async function getReservationsByTimeRange(roomId: string | null, startTime: Date, endTime: Date): Promise<
    { success: true; reservations: Reservation[] } | { success: false; error: any }
> {
  console.log('getReservationsByTimeRange called with:', { startTime, endTime });

  try {
    const result = await prisma.reservation.findMany({
      where: {
        ...(roomId ? { roomId } : {}),
        AND: [
          { timeStart: { lt: endTime } },  // reservation starts before range ends
          { timeEnd: { gt: startTime } }   // reservation ends after range starts
        ]
      }
    });

    console.log('Reservations fetched:', result);

    return {
      success: true,
      reservations: result
    };
  } catch (error) {
    console.error('Error fetching reservations by time range:', error);
    return {
      success: false,
      error
    };
  }
}

// delete a existing reservation
export async function deleteReservationById(reservationId: number): Promise<
    { success: true; reservation: Reservation } | { success: false; error: any }
> {
        console.log('deleteReservationById called with reservationId:', reservationId);
    try {
        const result = await prisma.reservation.delete({ 
            where: { 
                reservationId: reservationId
            } 
        });
            console.log('Reservation deleted:', result);
        return {
            success: true,
            reservation: result
        };
    } catch (error) {
        console.error('Error deleting reservation by ID:', error);
        return {
            success: false,
            error
        };
    }
}

// delete a group of reservations by seriesId
export async function deleteReservationBySeriesId(seriesId: string): Promise<
    { success: true; deleted: number } | { success: false; error: any }
> {
        console.log('deleteReservationBySeriesId called with seriesId:', seriesId);
    try {
        const result = await prisma.reservation.deleteMany({ 
            where: { 
                seriesId: seriesId
            } 
        });
            console.log('Reservations deleted:', result);
        return {
            success: true,
            deleted: result.count
        };
    } catch (error) {
        console.error('Error deleting reservation by series ID:', error);
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
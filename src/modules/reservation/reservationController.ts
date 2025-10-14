/*
  File: reservationController.ts
  Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
  Description: Main reservation logics
    - Conflicts check
    - Recursively insert and edit reservations
  Lasted Modify: 2025-10-14 22.03
*/

import { PrismaClient } from "@prisma/client";
import { randomUUID } from "crypto";

const prisma = new PrismaClient()
// use `prisma` in your application to read and write data in your DB


const WEEK_MS = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds

type Slot = {
  timeStart: Date;
  timeEnd: Date;
};


// Helper: check time overlap
function isOverlap(startA: Date, endA: Date, startB: Date, endB: Date): boolean {
    return startA < endB && endA > startB;
}


// Generate repeated weekly slots
function generateWeeklySlots(timeStart: Date, timeEnd: Date, rep: number): Slot[] {
  const slots: Slot[] = [];

  // Convert input strings to Date objects
  let currentStart = timeStart;
  let currentEnd = timeEnd;

  for (let i = 0; i < rep; i++) {
    slots.push({
      timeStart: currentStart,
      timeEnd: currentEnd,
    });

    // Increment date by 7 days
    currentStart = new Date(currentStart.getTime() + WEEK_MS);
    currentEnd   = new Date(currentEnd.getTime()   + WEEK_MS);
  }

  return slots;
}


// Check conflicts on given time slots
async function checkConflicts(seriesId: string | null, roomId: string, slots: Slot[]): Promise<boolean> {
  try {
    const reservationsOnSlotDates = await prisma.reservation.findMany({
      where: {
        roomId: roomId,
        OR: slots.map(slot => {
          const dayStart = new Date(slot.timeStart + 'T00:00:00.000Z');
          const dayEnd   = new Date(slot.timeStart + 'T23:59:59.999Z');
          return {
            timeStart: { lt: dayEnd },
            timeEnd:   { gt: dayStart },
          };
        }),
      },
      orderBy: { timeStart: 'asc' },
    });

    for (const slot of slots) {
      const slotStart = slot.timeStart;
      const slotEnd = slot.timeEnd;

      for (const res of reservationsOnSlotDates) {
        // Skip itself series if editing an existing reservation
        if (seriesId && res.seriesId === seriesId) continue;

        const resStart = res.timeStart;
        const resEnd = res.timeEnd;

        // Check for real overlap using helper function
        if (isOverlap(slotStart, slotEnd, resStart, resEnd)) {
          console.error(`Conflict detected: Room ${roomId} already booked from ${res.timeStart} to ${res.timeEnd}`);
          return true; // conflicts found
        }
      }
    }

    return false; // no conflicts
  } catch (error) {
    console.error('Error in checkConflicts:', error);
    throw error;
  }
}


// Adding reservation to database
export async function addReservation(roomId: string, timeStart: Date, timeEnd: Date, rep: number, competency: string): Promise<boolean> {
  const slots = generateWeeklySlots(timeStart, timeEnd, rep);
  const isConflict = await checkConflicts(null, roomId, slots);

  if (isConflict) {
    // slot(s) overlap, reservation fail
    return false;
  } else {
    // Insert slots into database
    const seriesId = randomUUID();
    const slotData = slots.map(slot => ({
      seriesId,
      roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency,
    }));
    try {
      await prisma.reservation.createMany({
        data: slotData
      });
      console.log("Reservations created successfully");
      return true;
    } catch (error) {
      console.error('Error inserting reservations:', error);
      return false;
    }
  }
}

// Edit existing reservations, grouped by seriesId
export async function editReservation(seriesId: string, roomId: string, timeStart: Date, timeEnd: Date, rep: number, competency: string): Promise<boolean> {
  const slots = generateWeeklySlots(timeStart, timeEnd, rep);
  const isConflict = await checkConflicts(seriesId, roomId, slots);

  if (isConflict) {
    // slot(s) overlap, reservation fail
    return false;
  } else {
    // Insert slots into database
    const seriesId = randomUUID();
    const slotData = slots.map(slot => ({
      seriesId,
      roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency,
    }));
    try {
      await prisma.reservation.deleteMany({
        where: {
          seriesId: seriesId
        }
      });
      await prisma.reservation.createMany({
        data: slotData
      });
      console.log("Reservations edited successfully");
      return true;
    } catch (error) {
      console.error('Error inserting reservations:', error);
      return false;
    }
  }
}


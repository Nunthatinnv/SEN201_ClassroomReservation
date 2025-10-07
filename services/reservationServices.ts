/*
	File: reservationServices.ts
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Main reservation logics
    - Conflicts check
    - Recursively upsert reservation
	Lasted Modify: 2025-10-07 17:14
*/

import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient()
// use `prisma` in your application to read and write data in your DB


const WEEK_MS = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds

type Slot = {
  timeStart: Date;
  timeEnd: Date;
};

type CheckConflictArgs = {
    reservationId?: number | null;
    roomId: string;
    timeStart: Date;
    timeEnd: Date;
    rep: number;
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


// Check conflicts
export async function checkConflicts({
  reservationId = null,
  roomId,
  timeStart,
  timeEnd,
  rep = 1
}: CheckConflictArgs): Promise<boolean> {
  const slots = generateWeeklySlots(timeStart, timeEnd, rep);

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
        // Skip itself if editing an existing reservation
        if (reservationId && res.reservationId === reservationId) continue;

        const resStart = res.timeStart;
        const resEnd = res.timeEnd;

        // Check for real overlap using helper function
        if (isOverlap(slotStart, slotEnd, resStart, resEnd)) {
          throw new Error(
            `Conflict detected: Room ${roomId} already booked from ${res.timeStart} to ${res.timeEnd}`
          );
        }
      }
    }

    return true; // no conflicts
  } catch (error) {
    console.error('Error in checkConflicts:', error);
    throw error;
  }
}

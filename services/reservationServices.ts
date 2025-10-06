/*
	File: reservationServices.js
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Main reservation logics
  - Conflicts check
  - Recursively upsert reservation
	Date: 2025-10-07
*/

import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient()
// use `prisma` in your application to read and write data in your DB


const WEEK_MS = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds

type Slot = {
  date: string;
  timeStart: string;
  timeEnd: string;
};

type CheckConflictArgs = {
    reservationId?: number | null;
    roomId: string;
    timeStart: string;   // "HH:mm:ss"
    timeEnd: string;     // "HH:mm:ss"
    rep: number;
};

// Helper: check time overlap
function isOverlap(startA: Date, endA: Date, startB: Date, endB: Date): boolean {
    return startA < endB && endA > startB;
}

// Convert date + time strings to timestamp
// function toTimestamp(date: string, time: string): number {
//     return new Date(`${date}T${time}`).getTime();
// }

// Generate repeated weekly slots
function generateWeeklySlots(timeStart: string, timeEnd: string, rep: number = 1): Slot[] {
    const slots: Slot[] = [];

    // Convert input strings to Date objects
    let currentStart = new Date(timeStart);
    let currentEnd = new Date(timeEnd);

    for (let i = 0; i < rep; i++) {
      slots.push({
        date: currentStart.toISOString().split('T')[0]!, // YYYY-MM-DD
        timeStart: currentStart.toISOString(),
        timeEnd: currentEnd.toISOString(),
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

  const reservationsOnSlotDates = await prisma.reservation.findMany({
    where: {
      roomId: roomId,
      OR: slots.map(slot => {
        const dayStart = new Date(slot.date + 'T00:00:00.000Z');
        const dayEnd   = new Date(slot.date + 'T23:59:59.999Z');
        return {
          timeStart: { lt: dayEnd },
          timeEnd:   { gt: dayStart },
        };
      }),
    },
    orderBy: { timeStart: 'asc' },
  });

  for (const slot of slots) {
    const slotStart = new Date(slot.timeStart);
    const slotEnd = new Date(slot.timeEnd);

    for (const res of reservationsOnSlotDates) {
      // Skip itself if editing an existing reservation
      if (reservationId && res.reservationId === reservationId) continue;

      const resStart = res.timeStart;
      const resEnd = res.timeEnd;

      // If the reservation ends before the slot starts OR
      // starts after the slot ends → no overlap, skip
      if (resEnd <= slotStart || resStart >= slotEnd) continue;

      // Check for real overlap using helper function
      if (isOverlap(slotStart, slotEnd, resStart, resEnd)) {
        throw new Error(
          `Conflict detected: Room ${roomId} already booked from ${res.timeStart} to ${res.timeEnd}`
        );
      }
    }
  }

  return true; // no conflicts
}

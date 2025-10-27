/*
  File: reservationController.ts
  Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
  Description: Main reservation logics
    - Conflicts check
    - Recursively insert and edit reservations
  Lasted Modify: 2025-10-14 23.08
*/

import { randomUUID } from "crypto";
import { deleteReservationBySeriesId, getReservationsByTimeRange } from "./reservationService";
import { createReservationBySlotData } from "./reservationService";
import type { Slot } from "../types";

const WEEK_MS = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds


// Helper function: check time overlap
function isOverlap(startA: Date, endA: Date, startB: Date, endB: Date): boolean {
    return startA < endB && endA > startB;
}


// Generate repeated weekly slots
// timeStart and timeEnd: timeslot of first week of reservation
// rep: number of weeks the reservation will repeat 
export function generateWeeklySlots(timeStart: Date, timeEnd: Date, rep: number): Slot[] {
  const slots: Slot[] = [];

  // Convert input strings to Date objects
  let currentStart = timeStart;
  let currentEnd = timeEnd;

  for (let i = 0; i < rep; i++) {
    slots.push({
      timeStart: currentStart,
      timeEnd: currentEnd,
    });

    // Increment date by 7 days, (Move to next week on same period)
    currentStart = new Date(currentStart.getTime() + WEEK_MS);
    currentEnd   = new Date(currentEnd.getTime()   + WEEK_MS);
  }

  return slots;
}


// Check conflicts on given time slots
async function checkConflicts(seriesId: string | null, roomId: string, slots: Slot[]): Promise<boolean> {
  if (!slots.length) return false;

  for (const slot of slots) {
    const slotStart = slot.timeStart;
    const dayStart = new Date(slotStart);
    const slotEnd = slot.timeEnd;
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd   = new Date(slotStart);
    dayEnd.setHours(23, 59, 59, 999);
    try {
      const result = await getReservationsByTimeRange(roomId ,dayStart, dayEnd);

      if (!result.success) {
        console.error("Error checking slot:", slot, result.error);
      } else {
        for (const res of result.reservations) {
          // skip if checking itself series.
          if (seriesId && res.seriesId === seriesId) continue;
          
          const resStart = res.timeStart;
          const resEnd = res.timeEnd;
          // Check for overlap conflicts using helper function
          if (isOverlap(slotStart, slotEnd, resStart, resEnd)) {
            console.error(`Conflict detected: Room ${roomId} already booked from ${res.timeStart} to ${res.timeEnd}`);
            return true; // conflicts found
          }
        }
      }
    } catch (error) {
      console.error('Error in checkConflicts:', error);
    }
  }
  return false; // no conflicts
}



// ---------- Repeatation Reservation Logics ----------

// Add a new reservation series to the database.
export async function addReservation(roomId: string, timeStart: Date, timeEnd: Date, rep: number, competency: string): Promise<boolean> {
  const slots = generateWeeklySlots(timeStart, timeEnd, rep);
  const isConflict = await checkConflicts(null, roomId, slots);

  if (isConflict) {
    return false; // slot(s) overlap, reservation fail
  } else {
    const seriesId = randomUUID();
    const newSlotData = slots.map(slot => ({
      seriesId,
      roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency,
    }));
    try {
      // Insert slots into database
      await createReservationBySlotData(newSlotData);
      console.log("Reservations created successfully");
      return true;
    } catch (error) {
      console.error('Error inserting reservations:', error);
      return false;
    }
  }
}


// Edit an existing reservation series by seriesId.
export async function editReservation(seriesId: string, roomId: string, timeStart: Date, timeEnd: Date, rep: number, competency: string): Promise<boolean> {
  const slots = generateWeeklySlots(timeStart, timeEnd, rep);
  const isConflict = await checkConflicts(seriesId, roomId, slots);

  if (isConflict) {
    return false; // slot overlap, reservation fail
  } else {
    // Insert slots into database
    const newSlotData = slots.map(slot => ({
      seriesId,
      roomId,
      timeStart: slot.timeStart,
      timeEnd: slot.timeEnd,
      competency,
    }));
    try {
      // delete existing reservation series
      await deleteReservationBySeriesId(seriesId);
      // add new reservation series with same seriesId
      await createReservationBySlotData(newSlotData);

      console.log("Reservations edited successfully");
      return true;
    } catch (error) {
      console.error('Error editing reservations:', error);
      return false;
    }
  }
}


// Delete all reservations in a series by seriesId.
export async function deleteReservation(seriesId: string): Promise<boolean> {
  try {
    await deleteReservationBySeriesId(seriesId);
    console.log("Reservations deleted successfully");
    return true;
  } catch (error) {
    console.error('Error inserting reservations:', error);
      return false;
  }
}
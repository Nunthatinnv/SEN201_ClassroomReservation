/*
	File: seriesService.ts
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Seires CRUD 
	Lasted Modify: 2025-10-27 20.43

	License: GNU General Public License Version 3.0
*/

import { PrismaClient } from "@prisma/client";
import type { Series } from "@prisma/client";

const prisma = new PrismaClient();


// create series with id, capacity and repetition
export async function createSeries(seriesId: string, capacity: number, repetition: number): Promise<
    { success: true; series: Series } | { success: false; error: any }
> {
    console.log('createSeriesById called with:', seriesId, capacity, repetition);
    const data: Series = {
        seriesId: seriesId,
        capacity: capacity,
        repetition: repetition,
    };
    try {
        const result = await prisma.series.create({
            data: data
        });
        console.log('Reservation created:', result);
        return { success: true, series: result };
    } catch (error) {
        console.error('Error creating reservation:', error);
        return { success: false, error };
    }
}


// edit series capacity and repetition by Id
export async function editSeriesbyId(seriesId: string, capacity: number, repetition: number): Promise<
  { success: true; series: Series } | { success: false; error: any }
> {
  console.log('editSeriesbyId called with:', { seriesId, capacity, repetition });
  
  try {
    const result = await prisma.series.update({
      where: {
        seriesId: seriesId,
      },
      data: {
        capacity: capacity,
        repetition: repetition,
      },
    });
    
    console.log('Series updated:', result);
    return { success: true, series: result };
  } catch (error) {
    console.error('Error updating series:', error);
    return { success: false, error };
  }
}


// delete series by Id
export async function deleteSeriesById(seriesId: string): Promise<
    { success: true; series: Series } | { success: false; error: any }
> {
        console.log('deleteSeriesById called with seriesId:', seriesId);
    try {
        const result = await prisma.series.delete({ 
            where: { 
                seriesId: seriesId
            } 
        });
            console.log('Reservation deleted:', result);
        return { success: true, series: result };
    } catch (error) {
        console.error('Error deleting reservation by ID:', error);
        return {
            success: false,
            error
        };
    }
}

/*
	File: types.ts
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Shared type definitions for reservation and slot data structures
	Lasted Modify: 2025-10-14 23.30
*/

export type SlotData = {
    seriesId: string;
    roomId: string;
    timeStart: Date;
    timeEnd: Date;
    competency: string,
}

export type Slot = {
  timeStart: Date;
  timeEnd: Date;
};
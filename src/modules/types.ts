/*
	File: types.ts
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Shared type definitions for reservation and slot data structures
  Modified by: Beam - Atchariyapat Sirijirakarnjareon (asiriji@cmkl.ac.th)
  Description: Add numberOfStudents to SlotData
	Lasted Modify: 2025-10-26 17.03
*/

export type SlotData = {
    seriesId: string;
    roomId: string;
    timeStart: Date;
    timeEnd: Date;
    competency: string,
    numberOfStudents: number;
}

export type Slot = {
  timeStart: Date;
  timeEnd: Date;
};
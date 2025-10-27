/*
	File: types.ts
	Author: Poon - Nunthatinn Veerapaiboon (nveerap@cmkl.ac.th)
	Description: Shared type definitions for reservation and slot data structures
    Modified by: Beam - Atchariyapat Sirijirakarnjareon (asiriji@cmkl.ac.th)
    Description: Added numberOfStudents to SlotData type.
	Lasted Modify: 2025-10-27 6:11pm
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
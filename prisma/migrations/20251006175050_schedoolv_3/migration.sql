/*
  Warnings:

  - The primary key for the `Reservations` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `Reservation_id` on the `Reservations` table. All the data in the column will be lost.
  - You are about to drop the column `Room_id` on the `Reservations` table. All the data in the column will be lost.
  - You are about to drop the column `Time_end` on the `Reservations` table. All the data in the column will be lost.
  - You are about to drop the column `Time_start` on the `Reservations` table. All the data in the column will be lost.
  - The primary key for the `Rooms` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `Capacity` on the `Rooms` table. All the data in the column will be lost.
  - You are about to drop the column `Equipment` on the `Rooms` table. All the data in the column will be lost.
  - You are about to drop the column `Room_id` on the `Rooms` table. All the data in the column will be lost.
  - You are about to drop the column `Room_name` on the `Rooms` table. All the data in the column will be lost.
  - Added the required column `reservation_id` to the `Reservations` table without a default value. This is not possible if the table is not empty.
  - Added the required column `room_id` to the `Reservations` table without a default value. This is not possible if the table is not empty.
  - Added the required column `time_end` to the `Reservations` table without a default value. This is not possible if the table is not empty.
  - Added the required column `time_start` to the `Reservations` table without a default value. This is not possible if the table is not empty.
  - Added the required column `capacity` to the `Rooms` table without a default value. This is not possible if the table is not empty.
  - Added the required column `room_id` to the `Rooms` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Reservations" (
    "reservation_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "room_id" TEXT NOT NULL,
    "time_start" DATETIME NOT NULL,
    "time_end" DATETIME NOT NULL,
    CONSTRAINT "Reservations_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "Rooms" ("room_id") ON DELETE RESTRICT ON UPDATE CASCADE
);
DROP TABLE "Reservations";
ALTER TABLE "new_Reservations" RENAME TO "Reservations";
CREATE TABLE "new_Rooms" (
    "room_id" TEXT NOT NULL PRIMARY KEY,
    "room_name" TEXT,
    "capacity" INTEGER NOT NULL,
    "equipment" TEXT
);
DROP TABLE "Rooms";
ALTER TABLE "new_Rooms" RENAME TO "Rooms";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

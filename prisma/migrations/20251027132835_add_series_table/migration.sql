/*
  Warnings:

  - You are about to drop the `Reservations` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Rooms` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Reservations";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Rooms";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "Room" (
    "room_id" TEXT NOT NULL PRIMARY KEY,
    "room_name" TEXT,
    "capacity" INTEGER NOT NULL,
    "equipments" TEXT
);

-- CreateTable
CREATE TABLE "Reservation" (
    "reservation_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "series_id" TEXT NOT NULL,
    "room_id" TEXT NOT NULL,
    "time_start" DATETIME NOT NULL,
    "time_end" DATETIME NOT NULL,
    "competency" TEXT NOT NULL,
    CONSTRAINT "Reservation_series_id_fkey" FOREIGN KEY ("series_id") REFERENCES "Series" ("series_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Reservation_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "Room" ("room_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Series" (
    "series_id" TEXT NOT NULL PRIMARY KEY,
    "capacity" INTEGER NOT NULL,
    "repeatation" INTEGER NOT NULL
);

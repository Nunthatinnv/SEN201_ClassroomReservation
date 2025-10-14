/*
  Warnings:

  - You are about to drop the column `reservation_group_id` on the `Reservations` table. All the data in the column will be lost.
  - Added the required column `series_id` to the `Reservations` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Reservations" (
    "reservation_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "series_id" TEXT NOT NULL,
    "room_id" TEXT NOT NULL,
    "time_start" DATETIME NOT NULL,
    "time_end" DATETIME NOT NULL,
    "competency" TEXT NOT NULL,
    CONSTRAINT "Reservations_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "Rooms" ("room_id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Reservations" ("competency", "reservation_id", "room_id", "time_end", "time_start") SELECT "competency", "reservation_id", "room_id", "time_end", "time_start" FROM "Reservations";
DROP TABLE "Reservations";
ALTER TABLE "new_Reservations" RENAME TO "Reservations";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

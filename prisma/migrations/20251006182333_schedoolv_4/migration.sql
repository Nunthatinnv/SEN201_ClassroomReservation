/*
  Warnings:

  - You are about to drop the column `equipment` on the `Rooms` table. All the data in the column will be lost.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Rooms" (
    "room_id" TEXT NOT NULL PRIMARY KEY,
    "room_name" TEXT,
    "capacity" INTEGER NOT NULL,
    "equipments" TEXT
);
INSERT INTO "new_Rooms" ("capacity", "room_id", "room_name") SELECT "capacity", "room_id", "room_name" FROM "Rooms";
DROP TABLE "Rooms";
ALTER TABLE "new_Rooms" RENAME TO "Rooms";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

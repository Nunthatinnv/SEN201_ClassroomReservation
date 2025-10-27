/*
  Warnings:

  - You are about to drop the column `repeatation` on the `Series` table. All the data in the column will be lost.
  - Added the required column `repetition` to the `Series` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Series" (
    "series_id" TEXT NOT NULL PRIMARY KEY,
    "capacity" INTEGER NOT NULL,
    "repetition" INTEGER NOT NULL
);
INSERT INTO "new_Series" ("capacity", "series_id") SELECT "capacity", "series_id" FROM "Series";
DROP TABLE "Series";
ALTER TABLE "new_Series" RENAME TO "Series";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

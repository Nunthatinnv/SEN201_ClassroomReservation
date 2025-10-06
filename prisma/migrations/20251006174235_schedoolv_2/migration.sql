-- CreateTable
CREATE TABLE "Rooms" (
    "Room_id" TEXT NOT NULL PRIMARY KEY,
    "Room_name" TEXT,
    "Capacity" INTEGER NOT NULL,
    "Equipment" TEXT
);

-- CreateTable
CREATE TABLE "Reservations" (
    "Reservation_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Room_id" TEXT NOT NULL,
    "Time_start" DATETIME NOT NULL,
    "Time_end" DATETIME NOT NULL,
    CONSTRAINT "Reservations_Room_id_fkey" FOREIGN KEY ("Room_id") REFERENCES "Rooms" ("Room_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

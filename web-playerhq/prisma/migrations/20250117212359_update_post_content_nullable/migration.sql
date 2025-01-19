/*
  Warnings:

  - You are about to drop the column `likes_count` on the `post` table. All the data in the column will be lost.
  - You are about to drop the column `ownedGames` on the `user` table. All the data in the column will be lost.
  - You are about to drop the `_userlikespost` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE `_userlikespost` DROP FOREIGN KEY `_UserLikesPost_A_fkey`;

-- DropForeignKey
ALTER TABLE `_userlikespost` DROP FOREIGN KEY `_UserLikesPost_B_fkey`;

-- AlterTable
ALTER TABLE `post` DROP COLUMN `likes_count`,
    MODIFY `content` VARCHAR(191) NULL;

-- AlterTable
ALTER TABLE `user` DROP COLUMN `ownedGames`;

-- DropTable
DROP TABLE `_userlikespost`;

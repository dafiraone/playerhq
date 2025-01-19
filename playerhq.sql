-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for playerhq
CREATE DATABASE IF NOT EXISTS `playerhq` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `playerhq`;

-- Dumping structure for table playerhq.comment
CREATE TABLE IF NOT EXISTS `comment` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`comment_id`),
  KEY `Comment_post_id_fkey` (`post_id`),
  KEY `Comment_user_id_fkey` (`user_id`),
  CONSTRAINT `Comment_post_id_fkey` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `Comment_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table playerhq.comment: ~5 rows (approximately)
INSERT INTO `comment` (`comment_id`, `post_id`, `user_id`, `content`, `created_at`, `updated_at`) VALUES
	(4, 2, 2, 'halo', '2025-01-18 14:49:46.230', '2025-01-18 14:49:46.230'),
	(5, 2, 2, 'P', '2025-01-18 15:07:20.519', '2025-01-18 15:07:20.519'),
	(10, 3, 2, 'Zelda', '2025-01-18 15:33:58.225', '2025-01-18 15:33:58.225'),
	(12, 2, 2, 'A', '2025-01-18 15:38:09.189', '2025-01-18 15:38:09.189'),
	(19, 18, 8, 'komen', '2025-01-19 14:08:29.384', '2025-01-19 14:08:29.384');

-- Dumping structure for table playerhq.post
CREATE TABLE IF NOT EXISTS `post` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `content` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`post_id`),
  KEY `Post_user_id_fkey` (`user_id`),
  CONSTRAINT `Post_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table playerhq.post: ~4 rows (approximately)
INSERT INTO `post` (`post_id`, `user_id`, `content`, `image`, `created_at`, `updated_at`) VALUES
	(1, 1, 'AEZAKMI', '1737212814238_85606.png', '2025-01-17 21:25:19.605', '2025-01-18 15:06:54.241'),
	(2, 2, 'ABOGOBOGA', '1737149127908_91001.png', '2025-01-17 21:25:27.911', '2025-01-18 11:16:12.760'),
	(3, 2, 'Best Game', '1737149144576_84169.png', '2025-01-17 21:25:44.579', '2025-01-19 10:17:18.665'),
	(18, 8, 'Hello', '1737295691132_12520.png', '2025-01-19 14:08:11.134', '2025-01-19 14:08:45.620');

-- Dumping structure for table playerhq.transaction
CREATE TABLE IF NOT EXISTS `transaction` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `game_api_id` int NOT NULL,
  `amount` double NOT NULL,
  `transaction_date` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `status` enum('BATAL','PENDING','BERHASIL') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `Transaction_user_id_fkey` (`user_id`),
  CONSTRAINT `Transaction_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table playerhq.transaction: ~6 rows (approximately)
INSERT INTO `transaction` (`transaction_id`, `user_id`, `game_api_id`, `amount`, `transaction_date`, `status`) VALUES
	(14, 2, 3328, 639840, '2025-01-19 09:30:24.088', 'BERHASIL'),
	(16, 4, 3498, 479680, '2025-01-19 09:46:10.977', 'BERHASIL'),
	(21, 2, 4200, 159840, '2025-01-19 12:26:07.009', 'BERHASIL'),
	(22, 8, 28, 275680, '2025-01-19 13:56:29.737', 'BERHASIL'),
	(24, 8, 5679, 211200, '2025-01-19 14:00:25.396', 'BERHASIL'),
	(25, 8, 3498, 479680, '2025-01-19 14:05:02.349', 'BERHASIL');

-- Dumping structure for table playerhq.user
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `role` enum('ADMIN','USER') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `User_username_key` (`username`),
  UNIQUE KEY `User_email_key` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table playerhq.user: ~6 rows (approximately)
INSERT INTO `user` (`user_id`, `username`, `email`, `password`, `image`, `bio`, `created_at`, `role`) VALUES
	(1, 'dafiraone', 'dafiraone@gmail.com', 'dafiraone', '1737211862902_72840.png', 'Developer', '2025-01-17 21:24:49.142', 'ADMIN'),
	(2, 'delirawan', 'delirawan@gmail.com', 'delirawan', '1737192566817_14241.png', '', '2025-01-17 21:24:54.741', 'USER'),
	(4, 'daffa', 'daffa', 'daffa', NULL, '', '2025-01-19 09:39:13.429', 'USER'),
	(6, 'a', 'aa@aa.com', 'a', NULL, 'a', '2025-01-19 09:42:16.841', 'USER'),
	(7, 'b', 'bb@bb.co', 'b', NULL, 'Biodata', '2025-01-19 09:51:14.309', 'USER'),
	(8, 'katon', 'katon@gmail.com', 'katon', '1737294795363_45277.png', 'Gamers', '2025-01-19 13:49:21.019', 'USER');

-- Dumping structure for table playerhq._prisma_migrations
CREATE TABLE IF NOT EXISTS `_prisma_migrations` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `finished_at` datetime(3) DEFAULT NULL,
  `migration_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logs` text COLLATE utf8mb4_unicode_ci,
  `rolled_back_at` datetime(3) DEFAULT NULL,
  `started_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `applied_steps_count` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table playerhq._prisma_migrations: ~0 rows (approximately)
INSERT INTO `_prisma_migrations` (`id`, `checksum`, `finished_at`, `migration_name`, `logs`, `rolled_back_at`, `started_at`, `applied_steps_count`) VALUES
	('623b00ee-e619-4133-9a47-18281845c480', '3a8d0595cd5cf5233b211388f28ebfd8a1af7c080b3a303b07dc66f3ea4b2db1', '2025-01-17 21:23:58.699', '20250116135153_init', NULL, NULL, '2025-01-17 21:23:58.337', 1),
	('63c470fe-0753-4132-83e5-4b19c6108bb4', '178039715db4bebc67234675533480a42068133d2eff0996d1f3acc032607d88', '2025-01-17 21:23:59.765', '20250117212359_update_post_content_nullable', NULL, NULL, '2025-01-17 21:23:59.672', 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

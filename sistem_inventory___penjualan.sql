-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 11, 2026 at 05:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sistem inventory & penjualan`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `BuatSalesOrder` (IN `p_id_pelanggan` INT, IN `p_id_gudang` INT)   BEGIN
  INSERT INTO sales_order 
    (tanggal_so, id_pelanggan, id_gudang, status_so, status_bayar)
  VALUES
    (NOW(), p_id_pelanggan, p_id_gudang, 'Draft', 'Belum Lunas');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CekKredit` (IN `p_id_pelanggan` INT, IN `p_total` DECIMAL(15,2))   BEGIN
  SELECT 
    nama_perusahaan,
    limit_kredit,
    sisa_hutang,
    (limit_kredit - sisa_hutang) AS sisa_kredit,
    CASE 
      WHEN (sisa_hutang + p_total) <= limit_kredit 
      THEN 'BOLEH ORDER'
      ELSE 'KREDIT PENUH'
    END AS status_kredit
  FROM pelanggan
  WHERE id_pelanggan = p_id_pelanggan;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `HistoriStok` (IN `p_id_produk` INT)   BEGIN
  SELECT 
    p.nama_produk,
    pg.jenis_pergerakan,
    pg.jumlah,
    g.nama_gudang,
    pg.waktu_log
  FROM pergerakan_stok pg
  JOIN produk p ON pg.id_produk = p.id_produk
  JOIN gudang g ON pg.id_gudang = g.id_gudang
  WHERE pg.id_produk = p_id_produk
  ORDER BY pg.waktu_log DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanStok` ()   BEGIN
  SELECT 
    p.nama_produk,
    p.stok_total,
    k.nama_kategori,
    ps.nama_pemasok
  FROM produk p
  JOIN kategori k ON p.id_kategori = k.id_kategori
  JOIN pemasok ps ON p.id_pemasok = ps.id_pemasok
  ORDER BY p.stok_total ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TerimaPO` (IN `p_id_po` INT)   BEGIN
  UPDATE purchase_order
  SET status_po = 'Diterima'
  WHERE id_po = p_id_po;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_item_po`
--

CREATE TABLE `detail_item_po` (
  `id_detail` int(11) NOT NULL,
  `id_po` int(11) NOT NULL,
  `id_produk` int(11) NOT NULL,
  `qty` int(11) DEFAULT NULL,
  `harga_beli` decimal(15,2) DEFAULT NULL,
  `subtotal` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_item_po`
--

INSERT INTO `detail_item_po` (`id_detail`, `id_po`, `id_produk`, `qty`, `harga_beli`, `subtotal`) VALUES
(1, 1, 1, 10, 50000.00, 500000.00),
(6, 2, 1, 5, 50000.00, 250000.00);

-- --------------------------------------------------------

--
-- Table structure for table `detail_item_so`
--

CREATE TABLE `detail_item_so` (
  `id_detail` int(11) NOT NULL,
  `id_so` int(11) DEFAULT NULL,
  `id_produk` int(11) DEFAULT NULL,
  `qty` int(11) DEFAULT NULL,
  `harga_satuan` decimal(15,2) DEFAULT NULL,
  `subtotal` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_item_so`
--

INSERT INTO `detail_item_so` (`id_detail`, `id_so`, `id_produk`, `qty`, `harga_satuan`, `subtotal`) VALUES
(1, 1, 1, 50, 20000.00, 1000000.00),
(4, 2, 1, 3, 50000.00, 150000.00);

-- --------------------------------------------------------

--
-- Table structure for table `gudang`
--

CREATE TABLE `gudang` (
  `id_gudang` int(11) NOT NULL,
  `nama_gudang` varchar(50) NOT NULL,
  `lokasi` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `gudang`
--

INSERT INTO `gudang` (`id_gudang`, `nama_gudang`, `lokasi`) VALUES
(1, 'Gudang Jakarta', 'Cakung, Jakarta Timur'),
(2, 'Gudang Surabaya', 'Rungkut, Surabaya');

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL,
  `nama_kategori` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id_kategori`, `nama_kategori`) VALUES
(1, 'Elektronik');

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama_perusahaan` varchar(100) NOT NULL,
  `limit_kredit` decimal(15,2) DEFAULT NULL,
  `sisa_hutang` decimal(15,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama_perusahaan`, `limit_kredit`, `sisa_hutang`) VALUES
(1, 'PT Abadi Makmur', 50000000.00, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `pemasok`
--

CREATE TABLE `pemasok` (
  `id_pemasok` int(11) NOT NULL,
  `nama_pemasok` varchar(100) NOT NULL,
  `kontak` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pemasok`
--

INSERT INTO `pemasok` (`id_pemasok`, `nama_pemasok`, `kontak`) VALUES
(1, 'PT Sumber Elektronik', '021-55001234');

-- --------------------------------------------------------

--
-- Table structure for table `pergerakan_stok`
--

CREATE TABLE `pergerakan_stok` (
  `id_log` int(11) NOT NULL,
  `id_produk` int(11) DEFAULT NULL,
  `id_gudang` int(11) DEFAULT NULL,
  `id_so` int(11) DEFAULT NULL,
  `jenis_pergerakan` enum('Masuk','Keluar') DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `waktu_log` timestamp NOT NULL DEFAULT current_timestamp(),
  `id_po` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pergerakan_stok`
--

INSERT INTO `pergerakan_stok` (`id_log`, `id_produk`, `id_gudang`, `id_so`, `jenis_pergerakan`, `jumlah`, `waktu_log`, `id_po`) VALUES
(1, 1, 1, NULL, 'Masuk', 500, '2026-04-07 06:38:53', NULL),
(5, 1, 1, NULL, 'Masuk', 5, '2026-04-27 07:13:37', NULL),
(6, 1, 1, 2, 'Keluar', 3, '2026-04-27 07:15:41', NULL);

--
-- Triggers `pergerakan_stok`
--
DELIMITER $$
CREATE TRIGGER `after_insert_pergerakan` AFTER INSERT ON `pergerakan_stok` FOR EACH ROW BEGIN
  IF NEW.jenis_pergerakan = 'Masuk' THEN
    UPDATE produk
    SET stok_total = stok_total + NEW.jumlah
    WHERE id_produk = NEW.id_produk;

  ELSEIF NEW.jenis_pergerakan = 'Keluar' THEN
    UPDATE produk
    SET stok_total = stok_total - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `produk`
--

CREATE TABLE `produk` (
  `id_produk` int(11) NOT NULL,
  `nama_produk` varchar(100) NOT NULL,
  `id_kategori` int(11) DEFAULT NULL,
  `id_pemasok` int(11) DEFAULT NULL,
  `harga_beli` decimal(15,2) DEFAULT NULL,
  `harga_jual` decimal(15,2) DEFAULT NULL,
  `stok_total` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produk`
--

INSERT INTO `produk` (`id_produk`, `nama_produk`, `id_kategori`, `id_pemasok`, `harga_beli`, `harga_jual`, `stok_total`) VALUES
(1, 'Kabel NYA 2.5mm', 1, 1, 15000.00, 20000.00, 502);

-- --------------------------------------------------------

--
-- Table structure for table `purchase_order`
--

CREATE TABLE `purchase_order` (
  `id_po` int(11) NOT NULL,
  `id_pemasok` int(11) NOT NULL,
  `id_gudang` int(11) NOT NULL,
  `tanggal_po` date DEFAULT NULL,
  `status_po` enum('Draft','Dikirim','Diterima','Dibatalkan') DEFAULT NULL,
  `total_bayar` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchase_order`
--

INSERT INTO `purchase_order` (`id_po`, `id_pemasok`, `id_gudang`, `tanggal_po`, `status_po`, `total_bayar`) VALUES
(1, 1, 1, '2026-04-26', 'Diterima', 500000.00),
(2, 1, 1, '2026-04-27', 'Diterima', 500000.00);

--
-- Triggers `purchase_order`
--
DELIMITER $$
CREATE TRIGGER `after_update_po` AFTER UPDATE ON `purchase_order` FOR EACH ROW BEGIN
  IF NEW.status_po = 'Diterima' AND OLD.status_po != 'Diterima' THEN
    
    INSERT INTO pergerakan_stok
      (id_produk, id_gudang, id_so, jenis_pergerakan, jumlah, waktu_log)
    SELECT
      d.id_produk,
      NEW.id_gudang,
      NULL,
      'Masuk',
      d.qty,
      NOW()
    FROM detail_item_po d
    WHERE d.id_po = NEW.id_po;

  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sales_order`
--

CREATE TABLE `sales_order` (
  `id_so` int(11) NOT NULL,
  `tanggal_so` date DEFAULT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `id_gudang` int(11) DEFAULT NULL,
  `total_bayar` decimal(15,2) DEFAULT 0.00,
  `status_so` enum('Draft','Processed','Delivered') DEFAULT 'Draft',
  `status_bayar` enum('Lunas','Belum Lunas') DEFAULT 'Belum Lunas',
  `jatuh_tempo` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales_order`
--

INSERT INTO `sales_order` (`id_so`, `tanggal_so`, `id_pelanggan`, `id_gudang`, `total_bayar`, `status_so`, `status_bayar`, `jatuh_tempo`) VALUES
(1, '2025-01-05', 1, 1, 2500000.00, 'Delivered', 'Lunas', '2025-01-20'),
(2, '2026-04-27', 1, 1, 150000.00, 'Delivered', 'Belum Lunas', '2026-05-27');

--
-- Triggers `sales_order`
--
DELIMITER $$
CREATE TRIGGER `after_update_so` AFTER UPDATE ON `sales_order` FOR EACH ROW BEGIN
  IF NEW.status_so = 'Delivered' AND OLD.status_so != 'Delivered' THEN
    
    INSERT INTO pergerakan_stok
      (id_produk, id_gudang, id_so, jenis_pergerakan, jumlah, waktu_log)
    SELECT
      d.id_produk,
      NEW.id_gudang,
      NEW.id_so,
      'Keluar',
      d.qty,
      NOW()
    FROM detail_item_so d
    WHERE d.id_so = NEW.id_so;

  END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `detail_item_po`
--
ALTER TABLE `detail_item_po`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_po` (`id_po`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indexes for table `detail_item_so`
--
ALTER TABLE `detail_item_so`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_so` (`id_so`),
  ADD KEY `id_produk` (`id_produk`);

--
-- Indexes for table `gudang`
--
ALTER TABLE `gudang`
  ADD PRIMARY KEY (`id_gudang`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `pemasok`
--
ALTER TABLE `pemasok`
  ADD PRIMARY KEY (`id_pemasok`);

--
-- Indexes for table `pergerakan_stok`
--
ALTER TABLE `pergerakan_stok`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `id_produk` (`id_produk`),
  ADD KEY `id_gudang` (`id_gudang`),
  ADD KEY `fk_pergerakan_so` (`id_so`),
  ADD KEY `id_po` (`id_po`);

--
-- Indexes for table `produk`
--
ALTER TABLE `produk`
  ADD PRIMARY KEY (`id_produk`),
  ADD KEY `id_kategori` (`id_kategori`),
  ADD KEY `id_pemasok` (`id_pemasok`);

--
-- Indexes for table `purchase_order`
--
ALTER TABLE `purchase_order`
  ADD PRIMARY KEY (`id_po`),
  ADD KEY `id_pemasok` (`id_pemasok`),
  ADD KEY `id_gudang` (`id_gudang`);

--
-- Indexes for table `sales_order`
--
ALTER TABLE `sales_order`
  ADD PRIMARY KEY (`id_so`),
  ADD KEY `id_pelanggan` (`id_pelanggan`),
  ADD KEY `id_gudang` (`id_gudang`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `detail_item_po`
--
ALTER TABLE `detail_item_po`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `detail_item_so`
--
ALTER TABLE `detail_item_so`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `gudang`
--
ALTER TABLE `gudang`
  MODIFY `id_gudang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id_kategori` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id_pelanggan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pemasok`
--
ALTER TABLE `pemasok`
  MODIFY `id_pemasok` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pergerakan_stok`
--
ALTER TABLE `pergerakan_stok`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `produk`
--
ALTER TABLE `produk`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `purchase_order`
--
ALTER TABLE `purchase_order`
  MODIFY `id_po` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sales_order`
--
ALTER TABLE `sales_order`
  MODIFY `id_so` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_item_po`
--
ALTER TABLE `detail_item_po`
  ADD CONSTRAINT `detail_item_po_ibfk_1` FOREIGN KEY (`id_po`) REFERENCES `purchase_order` (`id_po`),
  ADD CONSTRAINT `detail_item_po_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `detail_item_so`
--
ALTER TABLE `detail_item_so`
  ADD CONSTRAINT `detail_item_so_ibfk_1` FOREIGN KEY (`id_so`) REFERENCES `sales_order` (`id_so`),
  ADD CONSTRAINT `detail_item_so_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`);

--
-- Constraints for table `pergerakan_stok`
--
ALTER TABLE `pergerakan_stok`
  ADD CONSTRAINT `fk_pergerakan_so` FOREIGN KEY (`id_so`) REFERENCES `sales_order` (`id_so`),
  ADD CONSTRAINT `pergerakan_stok_ibfk_1` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`),
  ADD CONSTRAINT `pergerakan_stok_ibfk_2` FOREIGN KEY (`id_gudang`) REFERENCES `gudang` (`id_gudang`),
  ADD CONSTRAINT `pergerakan_stok_ibfk_3` FOREIGN KEY (`id_po`) REFERENCES `purchase_order` (`id_po`);

--
-- Constraints for table `produk`
--
ALTER TABLE `produk`
  ADD CONSTRAINT `produk_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`),
  ADD CONSTRAINT `produk_ibfk_2` FOREIGN KEY (`id_pemasok`) REFERENCES `pemasok` (`id_pemasok`);

--
-- Constraints for table `purchase_order`
--
ALTER TABLE `purchase_order`
  ADD CONSTRAINT `purchase_order_ibfk_1` FOREIGN KEY (`id_pemasok`) REFERENCES `pemasok` (`id_pemasok`),
  ADD CONSTRAINT `purchase_order_ibfk_2` FOREIGN KEY (`id_gudang`) REFERENCES `gudang` (`id_gudang`);

--
-- Constraints for table `sales_order`
--
ALTER TABLE `sales_order`
  ADD CONSTRAINT `sales_order_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`),
  ADD CONSTRAINT `sales_order_ibfk_2` FOREIGN KEY (`id_gudang`) REFERENCES `gudang` (`id_gudang`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

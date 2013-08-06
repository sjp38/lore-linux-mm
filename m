Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 19F166B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 07:37:06 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p11so232705pdj.32
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 04:37:05 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2 2/4] zcache: staging: %s/ZCACHE/ZCACHE_OLD
Date: Tue,  6 Aug 2013 19:36:15 +0800
Message-Id: <1375788977-12105-3-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: gregkh@linuxfoundation.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org, Bob Liu <bob.liu@oracle.com>

If nobody are using it, I'll drop it from staging.
Zcache in staging then split to zswap and zcache in mm/, and can be merged
again in future if there is requriement.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 drivers/staging/zcache/Kconfig  |   12 ++++++------
 drivers/staging/zcache/Makefile |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 2d7b2da..f96fb12 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -1,4 +1,4 @@
-config ZCACHE
+config ZCACHE_OLD
 	tristate "Dynamic compression of swap pages and clean pagecache pages"
 	depends on CRYPTO=y && SWAP=y && CLEANCACHE && FRONTSWAP
 	select CRYPTO_LZO
@@ -10,9 +10,9 @@ config ZCACHE
 	  memory to store clean page cache pages and swap in RAM,
 	  providing a noticeable reduction in disk I/O.
 
-config ZCACHE_DEBUG
+config ZCACHE_OLD_DEBUG
 	bool "Enable debug statistics"
-	depends on DEBUG_FS && ZCACHE
+	depends on DEBUG_FS && ZCACHE_OLD
 	default n
 	help
 	  This is used to provide an debugfs directory with counters of
@@ -20,7 +20,7 @@ config ZCACHE_DEBUG
 
 config RAMSTER
 	tristate "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE
+	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE_OLD
 	depends on NET
 	# must ensure struct page is 8-byte aligned
 	select HAVE_ALIGNED_STRUCT_PAGE if !64BIT
@@ -45,9 +45,9 @@ config RAMSTER_DEBUG
 # __add_to_swap_cache, and implement __swap_writepage (which is swap_writepage
 # without the frontswap call. When these are in-tree, the dependency on
 # BROKEN can be removed
-config ZCACHE_WRITEBACK
+config ZCACHE_OLD_WRITEBACK
 	bool "Allow compressed swap pages to be writtenback to swap disk"
-	depends on ZCACHE=y && BROKEN
+	depends on ZCACHE_OLD=y && BROKEN
 	default n
 	help
 	  Zcache caches compressed swap pages (and other data) in RAM which
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 845a5c2..34d27bd 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -1,8 +1,8 @@
 zcache-y	:=		zcache-main.o tmem.o zbud.o
-zcache-$(CONFIG_ZCACHE_DEBUG) += debug.o
+zcache-$(CONFIG_ZCACHE_OLD_DEBUG) += debug.o
 zcache-$(CONFIG_RAMSTER_DEBUG) += ramster/debug.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
 
-obj-$(CONFIG_ZCACHE)	+=	zcache.o
+obj-$(CONFIG_ZCACHE_OLD)	+=	zcache.o
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

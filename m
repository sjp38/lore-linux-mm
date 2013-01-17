Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 8A1CC6B000A
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 12:26:49 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 3/5] staging: zcache: adjustments to config/build files due to renaming
Date: Thu, 17 Jan 2013 09:26:35 -0800
Message-Id: <1358443597-9845-4-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

In staging/zcache, adjust config/build due to ramster->zcache renaming

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/zcache/Kconfig  |   17 ++++++-----------
 drivers/staging/zcache/Makefile |    2 +-
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 3abf661..c1dbd04 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -1,23 +1,18 @@
-config ZCACHE2
+config ZCACHE
 	bool "Dynamic compression of swap pages and clean pagecache pages"
-	depends on CRYPTO=y && SWAP=y && CLEANCACHE && FRONTSWAP && !ZCACHE 
+	depends on CRYPTO=y && SWAP=y && CLEANCACHE && FRONTSWAP
 	select CRYPTO_LZO
 	default n
 	help
-	  Zcache2 doubles RAM efficiency while providing a significant
-	  performance boosts on many workloads.  Zcache2 uses
+	  Zcache doubles RAM efficiency while providing a significant
+	  performance boosts on many workloads.  Zcache uses
 	  compression and an in-kernel implementation of transcendent
 	  memory to store clean page cache pages and swap in RAM,
-	  providing a noticeable reduction in disk I/O.  Zcache2
-	  is a complete rewrite of the older zcache; it was intended to
-	  be a merge but that has been blocked due to political and
-	  technical disagreements.  It is intended that they will merge
-	  again in the future.  Until then, zcache2 is a single-node
-	  version of ramster.
+	  providing a noticeable reduction in disk I/O.
 
 config RAMSTER
 	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE2=y
+	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE=y
 	depends on NET
 	# must ensure struct page is 8-byte aligned
 	select HAVE_ALIGNED_STRUCT_PAGE if !64_BIT
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 2d8b9d0..4711049 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -3,4 +3,4 @@ zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
 
-obj-$(CONFIG_ZCACHE2)	+=	zcache.o
+obj-$(CONFIG_ZCACHE)	+=	zcache.o
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

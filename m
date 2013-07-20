Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 093F56B0033
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 11:24:12 -0400 (EDT)
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r6KFO8bU017793
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:24:09 GMT
Received: from aserz7021.oracle.com (aserz7021.oracle.com [141.146.126.230])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFO7ns026050
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:24:08 GMT
Received: from abhmt106.oracle.com (abhmt106.oracle.com [141.146.116.58])
	by aserz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r6KFO7pR013559
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 15:24:07 GMT
Message-ID: <51EAAB95.8080101@oracle.com>
Date: Sat, 20 Jul 2013 23:24:05 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Fwd: [PATCH 1/2] zcache: staging: %s/ZCACHE/ZCACHE_OLD
References: <1374331018-11045-2-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1374331018-11045-2-git-send-email-bob.liu@oracle.com>
Content-Type: multipart/mixed;
 boundary="------------010803070900080207020207"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------010803070900080207020207
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit




-------- Original Message --------
Subject: [PATCH 1/2] zcache: staging: %s/ZCACHE/ZCACHE_OLD
Date: Sat, 20 Jul 2013 22:36:57 +0800
From: Bob Liu <lliubbo@gmail.com>
CC: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com,
gregkh@linuxfoundation.org, ngupta@vflare.org, minchan@kernel.org,
  konrad.wilk@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de,
  riel@redhat.com, penberg@kernel.org, akpm@linux-foundation.org,
 Bob Liu <bob.liu@oracle.com>

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
 # __add_to_swap_cache, and implement __swap_writepage (which is
swap_writepage
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
diff --git a/drivers/staging/zcache/Makefile
b/drivers/staging/zcache/Makefile
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
Regards,
-Bob



--------------010803070900080207020207
Content-Type: text/plain; charset=UTF-8;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------010803070900080207020207--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

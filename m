Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4503B6B0036
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 20:36:31 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 10:27:25 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1ED492BB0054
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:26 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3D0aKGe10223982
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:20 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3D0aPSM027769
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 10:36:25 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART3 v3 5/6] staging: ramster/debug: Add CONFIG_RAMSTER_DEBUG Kconfig entry 
Date: Sat, 13 Apr 2013 08:36:09 +0800
Message-Id: <1365813371-19006-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365813371-19006-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Add CONFIG_RAMSTER_DEBUG Kconfig entry.

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Kconfig         |    8 ++++++++
 drivers/staging/zcache/Makefile        |    2 +-
 drivers/staging/zcache/ramster/debug.h |    2 +-
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index c3b8a10..05e87a1 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -33,6 +33,14 @@ config RAMSTER
 	  zcache2, compresses swap pages into local RAM, but then remotifies
 	  the compressed pages to another node in the RAMster cluster.
 
+config RAMSTER_DEBUG
+        bool "Enable ramster debug statistics"
+        depends on DEBUG_FS && RAMSTER
+        default n
+        help
+          This is used to provide an debugfs directory with counters of
+          how ramster is doing. You probably want to set this to 'N'.
+
 # Depends on not-yet-upstreamed mm patches to export end_swap_bio_write and
 # __add_to_swap_cache, and implement __swap_writepage (which is swap_writepage
 # without the frontswap call. When these are in-tree, the dependency on
diff --git a/drivers/staging/zcache/Makefile b/drivers/staging/zcache/Makefile
index 4956fa0..845a5c2 100644
--- a/drivers/staging/zcache/Makefile
+++ b/drivers/staging/zcache/Makefile
@@ -1,6 +1,6 @@
 zcache-y	:=		zcache-main.o tmem.o zbud.o
 zcache-$(CONFIG_ZCACHE_DEBUG) += debug.o
-zcache-$(CONFIG_RAMSTER) += ramster/debug.o
+zcache-$(CONFIG_RAMSTER_DEBUG) += ramster/debug.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/ramster.o ramster/r2net.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-$(CONFIG_RAMSTER)	+=	ramster/heartbeat.o ramster/masklog.o
diff --git a/drivers/staging/zcache/ramster/debug.h b/drivers/staging/zcache/ramster/debug.h
index 7b2deaa..7f80dd4 100644
--- a/drivers/staging/zcache/ramster/debug.h
+++ b/drivers/staging/zcache/ramster/debug.h
@@ -1,4 +1,4 @@
-#ifdef CONFIG_RAMSTER
+#ifdef CONFIG_RAMSTER_DEBUG
 
 extern long ramster_flnodes;
 static atomic_t ramster_flnodes_atomic = ATOMIC_INIT(0);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7C3546B003C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 20:26:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 05:51:38 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 23533E0054
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:58:08 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A0QFJO12452206
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:56:15 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A0QI4M016424
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 10:26:18 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 07/10] staging: ramster/debug: Add RAMSTER_DEBUG Kconfig entry 
Date: Wed, 10 Apr 2013 08:25:57 +0800
Message-Id: <1365553560-32258-8-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Add RAMSTER_DEBUG Kconfig entry.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Kconfig |    8 ++++++++
 1 file changed, 8 insertions(+)

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
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

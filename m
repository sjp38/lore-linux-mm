Date: Thu, 22 Sep 2005 13:07:47 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Increase maximum kmalloc size to 256K
Message-ID: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, manfred@colorfulllife.com
List-ID: <linux-mm.kvack.org>

The workqueue structure can grow larger than 128k under 2.6.14-rc2 (with 
all debugging features enabled on 64 bit platforms) which will make 
kzalloc for workqueue structure entries fail. This patch increases the 
maximum slab entry size to 256K.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc2/include/linux/kmalloc_sizes.h
===================================================================
--- linux-2.6.14-rc2.orig/include/linux/kmalloc_sizes.h	2005-09-19 20:00:41.000000000 -0700
+++ linux-2.6.14-rc2/include/linux/kmalloc_sizes.h	2005-09-22 12:41:19.000000000 -0700
@@ -19,8 +19,8 @@
 	CACHE(32768)
 	CACHE(65536)
 	CACHE(131072)
-#ifndef CONFIG_MMU
 	CACHE(262144)
+#ifndef CONFIG_MMU
 	CACHE(524288)
 	CACHE(1048576)
 #ifdef CONFIG_LARGE_ALLOCS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

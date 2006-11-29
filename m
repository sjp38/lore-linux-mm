Date: Tue, 28 Nov 2006 16:44:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004442.11682.725.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/8] Get rid of SLAB_NOIO
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_NOIO

SLAB_NOIO is an alias of GFP_NOIO with a single instance of use.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/drivers/usb/storage/transport.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/storage/transport.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/storage/transport.c	2006-11-28 16:07:57.000000000 -0800
@@ -427,7 +427,7 @@
 	US_DEBUGP("%s: xfer %u bytes, %d entries\n", __FUNCTION__,
 			length, num_sg);
 	result = usb_sg_init(&us->current_sg, us->pusb_dev, pipe, 0,
-			sg, num_sg, length, SLAB_NOIO);
+			sg, num_sg, length, GFP_NOIO);
 	if (result) {
 		US_DEBUGP("usb_sg_init returned %d\n", result);
 		return USB_STOR_XFER_ERROR;
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:07:42.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:08:11.000000000 -0800
@@ -18,7 +18,6 @@
 
 /* flags for kmem_cache_alloc() */
 #define	SLAB_NOFS		GFP_NOFS
-#define	SLAB_NOIO		GFP_NOIO
 #define	SLAB_ATOMIC		GFP_ATOMIC
 #define	SLAB_USER		GFP_USER
 #define	SLAB_KERNEL		GFP_KERNEL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

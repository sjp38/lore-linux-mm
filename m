Date: Sat, 30 Sep 2006 11:48:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609301147550.4012@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060924030643.e57f700c.akpm@osdl.org> <20060927021934.9461b867.akpm@osdl.org>
 <451A6034.20305@shadowen.org> <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Insure that ZONEID_PGSHIFT is set even if ZONES_WIDTH is 0.

Andy needs to review this.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.18-mm2.orig/include/linux/mm.h	2006-09-30 13:23:06.604463587 -0500
+++ linux-2.6.18-mm2/include/linux/mm.h	2006-09-30 13:33:27.443455364 -0500
@@ -421,7 +421,12 @@ void split_page(struct page *page, unsig
 #else
 #define ZONEID_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
 #endif
+
+#if ZONES_WIDTH > 0
 #define ZONEID_PGSHIFT		ZONES_PGSHIFT
+#else
+#define ZONEID_PGSHIFT		NODES_PGOFF
+#endif
 
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

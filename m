Date: Mon, 7 May 2007 16:10:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/17] SLUB: Add support for dynamic cacheline size
 determination
In-Reply-To: <20070507212407.513642739@sgi.com>
Message-ID: <Pine.LNX.4.64.0705071607330.20619@schroedinger.engr.sgi.com>
References: <20070507212240.254911542@sgi.com> <20070507212407.513642739@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

cache_line_size is not available on all arches. So we need the following 
fix in addition to this patch:


SLUB: Fix *86ism: cache_line_size is not defined on all arches.

Define cache_line_size if it is not provided by the arch.

This should be done more elegantly someday.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/slub.c	2007-05-07 16:04:28.000000000 -0700
+++ linux-2.6.21-mm1/mm/slub.c	2007-05-07 16:05:02.000000000 -0700
@@ -1709,6 +1709,11 @@ static inline int calculate_order(int si
 	return -ENOSYS;
 }
 
+/* Not all arches define cache_line_size */
+#ifndef cache_line_size
+#define cache_line_size()	L1_CACHE_BYTES
+#endif
+
 /*
  * Figure out what the alignment of the objects will be.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

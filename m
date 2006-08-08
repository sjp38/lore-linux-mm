Date: Tue, 8 Aug 2006 10:51:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <Pine.LNX.4.64.0608081807380.24142@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0608081049040.28259@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
 <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081807380.24142@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Mel Gorman wrote:

> > From your set of patches, it's only used for page migration and the IA64 
> uncached allocator both of which are using alloc_pages_node() at the moment.
> Do you see a widespread need to avoid fallbacks in other areas?

These are the patches that are ready for mm. Read the other RFCs on 
linux-mm. There are patches for the slab etc.
 
> Also, I just noticed you didn't update GFP_LEVEL_MASK with your new flag. That
> may cause interesting failures in the future, particularly if you call into
> the slab allocator with the new flag.

Thanks! Fixup:

Index: linux-2.6.18-rc3-mm2/include/linux/gfp.h
===================================================================
--- linux-2.6.18-rc3-mm2.orig/include/linux/gfp.h	2006-08-08 09:20:41.727897528 -0700
+++ linux-2.6.18-rc3-mm2/include/linux/gfp.h	2006-08-08 10:50:37.604766523 -0700
@@ -54,7 +54,7 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE)
 
 /* This equals 0, but use constants in case they ever change */
 #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 7 May 2007 19:41:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/17] SLUB: Clean up krealloc
In-Reply-To: <20070507212408.951409595@sgi.com>
Message-ID: <Pine.LNX.4.64.0705071941120.26879@schroedinger.engr.sgi.com>
References: <20070507212240.254911542@sgi.com> <20070507212408.951409595@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmmmm... Compile failure on 32bit.

Use size_t in krealloc otherwise min() will complain.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/slub.c	2007-05-07 19:39:47.000000000 -0700
+++ linux-2.6.21-mm1/mm/slub.c	2007-05-07 19:40:06.000000000 -0700
@@ -2391,7 +2391,7 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 void *krealloc(const void *p, size_t new_size, gfp_t flags)
 {
 	void *ret;
-	unsigned long ks;
+	size_t ks;
 
 	if (unlikely(!p))
 		return kmalloc(new_size, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

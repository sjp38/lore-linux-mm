Date: Thu, 14 Dec 2006 09:03:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slab: fix kmem_ptr_validate prototype
In-Reply-To: <1166099200.32332.233.camel@twins>
Message-ID: <Pine.LNX.4.64.0612140857240.29461@schroedinger.engr.sgi.com>
References: <1166099200.32332.233.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The declaration of kmem_ptr_validate in slab.h does not match the
one in slab.c. Remove the fastcall attribute (this is the only use in 
slab.c).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-12-14 08:56:59.000000000 -0800
+++ linux-2.6/mm/slab.c	2006-12-14 08:57:10.000000000 -0800
@@ -3553,7 +3553,7 @@ EXPORT_SYMBOL(kmem_cache_zalloc);
  *
  * Currently only used for dentry validation.
  */
-int fastcall kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr)
+int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr)
 {
 	unsigned long addr = (unsigned long)ptr;
 	unsigned long min_addr = PAGE_OFFSET;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

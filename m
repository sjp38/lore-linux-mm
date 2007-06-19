Date: Tue, 19 Jun 2007 15:38:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 10/26] SLUB: Faster more efficient slab determination
 for __kmalloc.
In-Reply-To: <20070619152957.a03fbb2c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706191533580.7633@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095915.826976488@sgi.com>
 <20070619130858.693ae66e.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706191522230.7633@schroedinger.engr.sgi.com>
 <20070619152957.a03fbb2c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Andrew Morton wrote:

> On Tue, 19 Jun 2007 15:22:36 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 19 Jun 2007, Andrew Morton wrote:
> > 
> > > On Mon, 18 Jun 2007 02:58:48 -0700
> > > clameter@sgi.com wrote:
> > > 
> > > > +	BUG_ON(KMALLOC_MIN_SIZE > 256 ||
> > > > +		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
> > > 
> > > BUILD_BUG_ON?
> > > 
> > Does not matter. That code is __init.
> 
> Finding out at compile time is better.

Ok and BUILD_BUG_ON really works? Had some bad experiences with it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-19 15:36:57.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-19 15:37:05.000000000 -0700
@@ -3079,7 +3079,7 @@ void __init kmem_cache_init(void)
 	 * Make sure that nothing crazy happens if someone starts tinkering
 	 * around with ARCH_KMALLOC_MINALIGN
 	 */
-	BUG_ON(KMALLOC_MIN_SIZE > 256 ||
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
 	for (i = 8; i < KMALLOC_MIN_SIZE;i++)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

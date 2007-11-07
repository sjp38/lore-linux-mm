Date: Tue, 6 Nov 2007 19:07:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/23] SLUB: Add get() and kick() methods
In-Reply-To: <20071107023709.GU26163@stusta.de>
Message-ID: <Pine.LNX.4.64.0711061906290.5565@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011228.605750914@sgi.com>
 <20071107023709.GU26163@stusta.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007, Adrian Bunk wrote:

> A static inline dummy function for CONFIG_SLUB=n seems to be missing?

Correct. This patch is needed so that building with SLAB will work.


Slab defrag: Provide empty kmem_cache_setup_defrag function for SLAB.

Provide an empty function to satisfy dependencies for Slab defrag.

Signed-off-by: Christoph Lameter <clameter@sgi.com>?

---
 mm/slab.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-11-06 18:57:22.000000000 -0800
+++ linux-2.6/mm/slab.c	2007-11-06 18:58:40.000000000 -0800
@@ -2535,6 +2535,13 @@ static int __cache_shrink(struct kmem_ca
 	return (ret ? 1 : 0);
 }
 
+void kmem_cache_setup_defrag(struct kmem_cache *s,
+	void *(*get)(struct kmem_cache *, int nr, void **),
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private))
+{
+}
+EXPORT_SYMBOL(kmem_cache_setup_defrag);
+
 /**
  * kmem_cache_shrink - Shrink a cache.
  * @cachep: The cache to shrink.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

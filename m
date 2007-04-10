Date: Tue, 10 Apr 2007 14:21:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101416020.9522@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> Where do I go to learn what "s->defrag_ratio = 100;" means?


SLUB: add explanation for defrag_ratio = 100.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-10 14:16:33.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-10 14:19:05.000000000 -0700
@@ -961,6 +961,12 @@ static struct page *get_any_partial(stru
 	 *
 	 * A higher ratio means slabs may be taken from other nodes
 	 * thus reducing the number of partial slabs on those nodes.
+	 *
+	 * If /sys/slab/xx/defrag_ratio is set to 100 (which makes
+	 * defrag_ratio = 1000) then every (well almost) allocation
+	 * will first attempt to defrag slab caches on other nodes. This
+	 * means scanning over all nodes to look for partial slabs which
+	 * may be a bit expensive to do on every slab allocation.
 	 */
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

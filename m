Date: Thu, 10 Apr 2008 13:27:41 +0300 (EEST)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: git-slub crashes on the t16p
In-Reply-To: <20080410015958.bc2fd041.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI>
References: <20080410015958.bc2fd041.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008, Andrew Morton wrote:
> It's the tree I pulled about 12 hours ago.  Quite early in boot.
> 
> crash: http://userweb.kernel.org/~akpm/p4105087.jpg
> config: http://userweb.kernel.org/~akpm/config-t61p.txt
> git-slub.patch: http://userweb.kernel.org/~akpm/mmotm/broken-out/git-slub.patch
> 
> A t61p is a dual-core x86_64.
> 
> I was testing with all of the -mm series up to and including git-slub.patch
> applied.

Does the following patch fix it?

diff --git a/mm/slub.c b/mm/slub.c
index 4b694a7..3916b4d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -895,7 +895,7 @@ static inline void inc_slabs_node(struct kmem_cache *s, int node, int objects)
 	 * dilemma by deferring the increment of the count during
 	 * bootstrap (see early_kmem_cache_node_alloc).
 	 */
-	if (!NUMA_BUILD || n) {
+	if (n) {
 		atomic_long_inc(&n->nr_slabs);
 		atomic_long_add(objects, &n->total_objects);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A6BC96B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:34:10 -0400 (EDT)
Date: Fri, 28 Sep 2012 16:34:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] slub: init_kmem_cache_cpus() and put_cpu_partial() can be
 static
Message-ID: <20120928083405.GA23740@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>

Acked-by: Glauber Costa <glommer@parallels.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux.orig/mm/slub.c	2012-09-24 10:22:11.000000000 +0800
+++ linux/mm/slub.c	2012-09-28 16:31:31.987092387 +0800
@@ -1709,7 +1709,7 @@ static inline void note_cmpxchg_failure(
 	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
 }
 
-void init_kmem_cache_cpus(struct kmem_cache *s)
+static void init_kmem_cache_cpus(struct kmem_cache *s)
 {
 	int cpu;
 
@@ -1934,7 +1934,7 @@ static void unfreeze_partials(struct kme
  * If we did not find a slot then simply move all the partials to the
  * per node partial list.
  */
-int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
+static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 {
 	struct page *oldpage;
 	int pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

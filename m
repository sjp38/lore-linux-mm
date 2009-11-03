Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 087F16B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 23:27:43 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Message-Id: <200911031457.39368.rusty@rustcorp.com.au>
Date: Tue, 3 Nov 2009 14:57:39 +1030
Subject: [PATCH 7/14] cpumask: avoid deprecated function in mm/slab.c
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


These days we use cpumask_empty() which takes a pointer.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 mm/slab.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1120,7 +1120,7 @@ static void __cpuinit cpuup_canceled(lon
 		if (nc)
 			free_block(cachep, nc->entry, nc->avail, node);
 
-		if (!cpus_empty(*mask)) {
+		if (!cpumask_empty(mask)) {
 			spin_unlock_irq(&l3->list_lock);
 			goto free_array_cache;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

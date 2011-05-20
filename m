Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 858D16B0022
	for <linux-mm@kvack.org>; Fri, 20 May 2011 02:23:52 -0400 (EDT)
Date: Fri, 20 May 2011 16:23:47 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
Message-Id: <20110520162347.6c780d3b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus <torvalds@linux-foundation.org>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org

Hi all,

After merging the final tree, today's linux-next build (sparc32 defconfig)
failed like this:

mm/prio_tree.c: In function 'vma_prio_tree_next':
mm/prio_tree.c:178: error: implicit declaration of function 'prefetch'

Caused by commit e66eed651fd1 ("list: remove prefetching from regular list
iterators").

I added this patch  for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 20 May 2011 16:19:57 +1000
Subject: [PATCH] mm: include prefetch.h

Commit e66eed651fd1 ("list: remove prefetching from regular list
iterators") removed the include of prefetch.h from list.h, so include
it explicitly.

Fixes thids build error on sparc32:

mm/prio_tree.c: In function 'vma_prio_tree_next':
mm/prio_tree.c:178: error: implicit declaration of function 'prefetch'

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 mm/prio_tree.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/prio_tree.c b/mm/prio_tree.c
index 603ae98..799dcfd 100644
--- a/mm/prio_tree.c
+++ b/mm/prio_tree.c
@@ -13,6 +13,7 @@
 
 #include <linux/mm.h>
 #include <linux/prio_tree.h>
+#include <linux/prefetch.h>
 
 /*
  * See lib/prio_tree.c for details on the general radix priority search tree
-- 
1.7.5.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

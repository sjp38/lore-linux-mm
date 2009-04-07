From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/14] readahead: remove one unnecessary radix tree lookup
Date: Tue, 07 Apr 2009 19:50:47 +0800
Message-ID: <20090407115234.657957195@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D232C5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:51 -0400 (EDT)
Content-Disposition: inline; filename=readahead-interleaved-offset.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

(hit_readahead_marker != 0) means the page at @offset is present,
so we can search for non-present page starting from @offset+1.

Reported-by: Xu Chenfeng <xcf@ustc.edu.cn>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -420,7 +420,7 @@ ondemand_readahead(struct address_space 
 		pgoff_t start;
 
 		rcu_read_lock();
-		start = radix_tree_next_hole(&mapping->page_tree, offset,max+1);
+		start = radix_tree_next_hole(&mapping->page_tree, offset+1,max);
 		rcu_read_unlock();
 
 		if (!start || start - offset > max)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

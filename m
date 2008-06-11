Date: Wed, 11 Jun 2008 11:26:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: 2.6.26-rc5-mm2 (compile error in mm/memory_hotplug.c)
In-Reply-To: <20080609223145.5c9a2878.akpm@linux-foundation.org>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
Message-Id: <20080611112111.C7BE.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> lockess pagecache
>
> +vmscan-move-isolate_lru_page-to-vmscanc.patch
>   :

This patch is cause of compile error in mm/memory_hotplug.c.
Obviously, just here is old against changing interface of
isolate_lru_page(). :-(

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 mm/memory_hotplug.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c
+++ current/mm/memory_hotplug.c
@@ -595,8 +595,9 @@ do_migrate_range(unsigned long start_pfn
 		 * We can skip free pages. And we can only deal with pages on
 		 * LRU.
 		 */
-		ret = isolate_lru_page(page, &source);
+		ret = isolate_lru_page(page);
 		if (!ret) { /* Success */
+			list_add_tail(&page->lru, &source);
 			move_pages--;
 		} else {
 			/* Becasue we don't have big zone->lock. we should

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

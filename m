Date: Fri, 20 Jun 2008 12:09:52 +0800
From: Kent Liu <kent.liu@linux.intel.com>
Subject: [PATCH]Don't calculate vm_total_pages twice when rebuild zonelists
	in online_pages()
Message-ID: <20080620040952.GA18061@wliu-linux.bj.intel.com>
References: <20080619003844.GA14121@wliu-linux.bj.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080619003844.GA14121@wliu-linux.bj.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Resend the patch with more appropriate subject -- adding [PATCH] prefix.
Please consider it.

-----
If zonelist is required to be rebuilt in online_pages(), there is no need
to recalculate vm_total_pages in that function, as it has been updated 
in the call build_all_zonelists().

Signed-off-by: Kent Liu <kent.liu@linux.intel.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memory_hotplug.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 833f854..896ddaf 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -429,7 +429,9 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 
 	if (need_zonelists_rebuild)
 		build_all_zonelists();
-	vm_total_pages = nr_free_pagecache_pages();
+	else
+		vm_total_pages = nr_free_pagecache_pages();
+
 	writeback_set_ratelimit();
 
 	if (onlined_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

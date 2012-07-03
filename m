Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 58E2D6B0070
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 23:59:54 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [RFC PATCH 4/4] mm: change slob's struct page definition to accomodate struct page changes
Date: Tue, 3 Jul 2012 11:57:17 +0800
Message-ID: <1341287837-7904-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Changeset fc9bb8c768abe7ae10861c3510e01a95f98d5933 "mm: Rearrange struct page"
rearranges fields in struct page, so change slob's "struct page" definition
to accomodate the changes.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/slob.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 2c1fa9c..e5515bb 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -100,10 +100,10 @@ struct slob_page {
 	union {
 		struct {
 			unsigned long flags;	/* mandatory */
-			atomic_t _count;	/* mandatory */
-			slobidx_t units;	/* free units left in page */
-			unsigned long pad[2];
+			unsigned long pad1;
 			slob_t *free;		/* first free slob_t in page */
+			slobidx_t units;	/* free units left in page */
+			atomic_t _count;	/* mandatory */
 			struct list_head list;	/* linked list of free pages */
 		};
 		struct page page;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

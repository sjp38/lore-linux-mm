Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C08B98D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 22:06:02 -0500 (EST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 40/44] mm/hugetlb.c: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:59 -0800
Message-Id: <59705f848d35b12ace640f92afcffea02cee0976.1289789605.git.joe@perches.com>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Jiri Kosina <trivial@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/hugetlb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c4a3558..8875242 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -540,7 +540,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;;
+		goto err;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302DE6B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 19:35:51 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n19-v6so5732686pgv.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 16:35:51 -0700 (PDT)
Received: from mxhk.zte.com.cn (mxhk.zte.com.cn. [63.217.80.70])
        by mx.google.com with ESMTPS id g70-v6si16172089pfe.4.2018.07.25.16.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 16:35:49 -0700 (PDT)
From: Jiang Biao <jiang.biao2@zte.com.cn>
Subject: [PATCH] mm/vmscan: fix page_freeze_refs in comment.
Date: Thu, 26 Jul 2018 07:34:17 +0800
Message-Id: <1532561657-98783-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jiang.biao2@zte.com.cn, zhong.weidong@zte.com.cn

page_freeze_refs has already been relplaced by page_ref_freeze, but
it is not modified in the comment.

Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f8..d29e207 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -744,7 +744,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		refcount = 2;
 	if (!page_ref_freeze(page, refcount))
 		goto cannot_free;
-	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
+	/* note: atomic_cmpxchg in page_refs_freeze provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
 		page_ref_unfreeze(page, refcount);
 		goto cannot_free;
-- 
2.7.4

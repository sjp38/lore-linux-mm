Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id F35F582F66
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:29 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so10059400pad.3
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id rt6si22557131pab.69.2015.10.15.09.04.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:28 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/6] ksm: use the helper method to do the hlist_empty check
Date: Thu, 15 Oct 2015 18:04:23 +0200
Message-Id: <1444925065-4841-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

This just uses the helper function to cleanup the assumption on the
hlist_node internals.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 929b5c2..241588e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -661,7 +661,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
 		unlock_page(page);
 		put_page(page);
 
-		if (stable_node->hlist.first)
+		if (!hlist_empty(&stable_node->hlist))
 			ksm_pages_sharing--;
 		else
 			ksm_pages_shared--;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id D78DF82F65
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:41 -0500 (EST)
Received: by iodd200 with SMTP id d200so149948381iod.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si12864701igx.27.2015.11.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:34 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/5] ksm: use the helper method to do the hlist_empty check
Date: Mon,  2 Nov 2015 18:01:29 +0100
Message-Id: <1446483691-8494-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

This just uses the helper function to cleanup the assumption on the
hlist_node internals.

Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9f182f9..d4ee159 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -625,7 +625,7 @@ static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
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

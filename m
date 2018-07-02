Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA006B028F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:02:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g20-v6so9263471pfi.2
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:02:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c198-v6sor3352805pga.143.2018.07.02.15.02.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 15:02:15 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] fs-mm-account-buffer_head-to-kmemcg.patch.fix
Date: Mon,  2 Jul 2018 15:02:08 -0700
Message-Id: <20180702220208.213380-1-shakeelb@google.com>
In-Reply-To: <20180627191250.209150-3-shakeelb@google.com>
References: <20180627191250.209150-3-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

The patch "fs, mm: account buffer_head to kmemcg" missed to add
__GFP_ACCOUNT flag into the gfp mask for directed memcg charging. So,
adding it. Andrew, please squash this into the original patch.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/buffer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index e08863af56f6..405d4723ed3d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -814,7 +814,7 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		bool retry)
 {
 	struct buffer_head *bh, *head;
-	gfp_t gfp = GFP_NOFS;
+	gfp_t gfp = GFP_NOFS | __GFP_ACCOUNT;
 	long offset;
 	struct mem_cgroup *memcg;
 
-- 
2.18.0.399.gad0ab374a1-goog

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8C36B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:26:40 -0400 (EDT)
Received: by oiar126 with SMTP id r126so34850096oia.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 05:26:40 -0700 (PDT)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id oj3si7430460oeb.27.2015.10.12.05.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 05:26:39 -0700 (PDT)
Received: by obbzf10 with SMTP id zf10so105082073obb.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 05:26:39 -0700 (PDT)
From: Liao Tonglang <liaotonglang@gmail.com>
Subject: [PATCH] mm: cleanup balance_dirty_pages() that leave variables uninitialized
Date: Mon, 12 Oct 2015 20:24:58 +0800
Message-Id: <1444652698-28292-1-git-send-email-liaotonglang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, axboe@fb.com, akpm@linux-foundation.org, jack@suse.cz, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Liao Tonglang <liaotonglang@gmail.com>

Variables m_thresh and m_dirty in function balance_dirty_pages() may use
uninitialized. GCC throws a warning on it. Fixed by assigned to 0 as
initial value.

Signed-off-by: Liao Tonglang <liaotonglang@gmail.com>
---
 mm/page-writeback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0a931cd..288db45 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1534,7 +1534,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	for (;;) {
 		unsigned long now = jiffies;
 		unsigned long dirty, thresh, bg_thresh;
-		unsigned long m_dirty, m_thresh, m_bg_thresh;
+		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh;
 
 		/*
 		 * Unstable writes are a feature of certain networked
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

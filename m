Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 413E66B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 12:30:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so19105284wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 09:30:29 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0102.outbound.protection.outlook.com. [104.47.1.102])
        by mx.google.com with ESMTPS id e137si7385292wmf.46.2016.05.23.09.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 09:30:28 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm: kasan: remove unused 'reserved' field from struct kasan_alloc_meta
Date: Mon, 23 May 2016 19:30:54 +0300
Message-ID: <1464021054-2307-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Commit cd11016e5f52 ("mm, kasan: stackdepot implementation. Enable stackdepot for SLAB")
added 'reserved' field, but never used it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7f7ac51..fb87923 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -77,7 +77,6 @@ struct kasan_alloc_meta {
 	struct kasan_track track;
 	u32 state : 2;	/* enum kasan_state */
 	u32 alloc_size : 30;
-	u32 reserved;
 };
 
 struct qlist_node {
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

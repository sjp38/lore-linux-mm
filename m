Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9318E0004
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:05:05 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g36-v6so10036361wrd.9
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:05:05 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50091.outbound.protection.outlook.com. [40.107.5.91])
        by mx.google.com with ESMTPS id w12-v6si4695304wrl.27.2018.09.14.06.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 06:05:04 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/3] mm/vmalloc: Improve vfree() kerneldoc
Date: Fri, 14 Sep 2018 16:05:11 +0300
Message-Id: <20180914130512.10394-2-aryabinin@virtuozzo.com>
In-Reply-To: <20180914130512.10394-1-aryabinin@virtuozzo.com>
References: <20180914130512.10394-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

vfree() might sleep if called not in interrupt context. Explain
that in the comment.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/vmalloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a728fc492557..d00d42d6bf79 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1577,6 +1577,8 @@ void vfree_atomic(const void *addr)
  *	have CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG, but making the calling
  *	conventions for vfree() arch-depenedent would be a really bad idea)
  *
+ *	May sleep if called *not* from interrupt context.
+ *
  *	NOTE: assumes that the object at @addr has a size >= sizeof(llist_node)
  */
 void vfree(const void *addr)
-- 
2.16.4

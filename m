Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3D23C6B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:46:52 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l6so182343542wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:46:52 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id m9si33608281wjx.242.2016.04.12.03.46.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:46:51 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id a140so48228110wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:46:51 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1] lib/stackdepot.c: allow the stack trace hash to be zero
Date: Tue, 12 Apr 2016 12:46:46 +0200
Message-Id: <e8d064377178b0a64f2e44c92c3c531a276ff4d5.1460457476.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, kcc@google.com, iamjoonsoo.kim@lge.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There's actually no point in reserving the zero hash value.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 lib/stackdepot.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index 654c9d8..9e0b031 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -210,10 +210,6 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 		goto fast_exit;
 
 	hash = hash_stack(trace->entries, trace->nr_entries);
-	/* Bad luck, we won't store this stack. */
-	if (hash == 0)
-		goto exit;
-
 	bucket = &stack_table[hash & STACK_HASH_MASK];
 
 	/*
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

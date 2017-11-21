Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2576B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:02:52 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f28so6727607otd.12
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 04:02:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g134si4990771oic.372.2017.11.21.04.02.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 04:02:50 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Date: Tue, 21 Nov 2017 21:02:37 +0900
Message-Id: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

There are users not checking for register_shrinker() failure.
Continuing with ignoring failure can lead to later oops at
unregister_shrinker().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/shrinker.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 388ff29..a389491 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -75,6 +75,6 @@ struct shrinker {
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
 
-extern int register_shrinker(struct shrinker *);
+extern __must_check int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
 #endif
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 031B36B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 01:36:28 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id sq19so175694086igc.0
        for <linux-mm@kvack.org>; Sun, 01 May 2016 22:36:28 -0700 (PDT)
Received: from out1134-235.mail.aliyun.com (out1134-235.mail.aliyun.com. [42.120.134.235])
        by mx.google.com with ESMTP id ii3si12556596igb.6.2016.05.01.22.36.26
        for <linux-mm@kvack.org>;
        Sun, 01 May 2016 22:36:27 -0700 (PDT)
From: chengang@emindsoft.com.cn
Subject: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
Date: Mon,  2 May 2016 13:36:14 +0800
Message-Id: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chen Gang <chengang@emindsoft.com.cn>, Chen Gang <gang.chen.5i5j@gmail.com>

From: Chen Gang <chengang@emindsoft.com.cn>

According to kasan_[dis|en]able_current() comments and the kasan_depth'
s initialization, if kasan_depth is zero, it means disable.

So need use "!!kasan_depth" instead of "!kasan_depth" for checking
enable.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/kasan/kasan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7da78a6..6464b8f 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -102,7 +102,7 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 
 static inline bool kasan_report_enabled(void)
 {
-	return !current->kasan_depth;
+	return !!current->kasan_depth;
 }
 
 void kasan_report(unsigned long addr, size_t size,
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C67D9680F7F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:31 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so155881965wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:31 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id cv6si10030522wjb.68.2016.01.27.10.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:27 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id p63so39775504wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:27 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 6/8] kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
Date: Wed, 27 Jan 2016 19:25:11 +0100
Message-Id: <543521b8a452188f870cd0e87fabb80e32d9e1a1.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Alexander Potapenko <glider@google.com>
---
 lib/test_kasan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 66dd92f..5498a78 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -286,6 +286,8 @@ static noinline void __init kmalloc_uaf2(void)
 	}
 
 	ptr1[40] = 'x';
+	if (ptr1 == ptr2)
+		pr_err("Could not detect use-after-free: ptr1 == ptr2\n");
 	kfree(ptr2);
 }
 
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

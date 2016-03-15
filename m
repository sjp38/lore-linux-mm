Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 42ACD828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 06:10:57 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so144125320wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 03:10:57 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id n6si32093596wjw.45.2016.03.15.03.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 03:10:50 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id p65so136903251wmp.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 03:10:49 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 6/7] kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
Date: Tue, 15 Mar 2016 11:10:35 +0100
Message-Id: <f52ae8e29bf172179da196db4af8cbc7f6de9c4b.1458036040.git.glider@google.com>
In-Reply-To: <cover.1458036040.git.glider@google.com>
References: <cover.1458036040.git.glider@google.com>
In-Reply-To: <cover.1458036040.git.glider@google.com>
References: <cover.1458036040.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Alexander Potapenko <glider@google.com>
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 lib/test_kasan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 90ad74f..82169fb 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -294,6 +294,8 @@ static noinline void __init kmalloc_uaf2(void)
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

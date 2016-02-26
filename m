Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7405C828DF
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:31:06 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so72651029wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:31:06 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id m66si4093122wma.102.2016.02.26.05.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 05:30:59 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id c200so72465686wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:30:59 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v3 6/7] kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
Date: Fri, 26 Feb 2016 14:30:45 +0100
Message-Id: <d9c01c66193b4a716dda9557fe68b0313792ef7e.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Alexander Potapenko <glider@google.com>
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

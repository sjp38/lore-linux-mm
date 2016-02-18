Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 116D8828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:16:28 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id a4so35471568wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:28 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id l11si6568117wmd.29.2016.02.18.09.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:16:27 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id c200so38580222wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:27 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 6/7] kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
Date: Thu, 18 Feb 2016 18:16:06 +0100
Message-Id: <453a4a22affea8061edf20b64f63f4a0d6359417.1455814741.git.glider@google.com>
In-Reply-To: <cover.1455811491.git.glider@google.com>
References: <cover.1455811491.git.glider@google.com>
In-Reply-To: <cover.1455814741.git.glider@google.com>
References: <cover.1455814741.git.glider@google.com>
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

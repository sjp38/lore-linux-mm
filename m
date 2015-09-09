Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4BA6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 00:11:20 -0400 (EDT)
Received: by obqa2 with SMTP id a2so101033267obq.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 21:11:20 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id op7si3782134obb.80.2015.09.08.21.11.18
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 21:11:19 -0700 (PDT)
From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH 1/2] lib: test_kasan: add some testcases
Date: Wed, 9 Sep 2015 03:59:39 +0000
Message-ID: <1441771180-206648-2-git-send-email-long.wanglong@huawei.com>
In-Reply-To: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ryabinin.a.a@gmail.com, adech.fo@gmail.com
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au, long.wanglong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

This patch add some out of bounds testcases to test_kasan
module.

Signed-off-by: Wang Long <long.wanglong@huawei.com>
---
 lib/test_kasan.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 69 insertions(+)

diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index c1efb1b..c32f3b0 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -138,6 +138,71 @@ static noinline void __init kmalloc_oob_16(void)
 	kfree(ptr2);
 }
 
+static noinline void __init kmalloc_oob_memset_2(void)
+{
+	char *ptr;
+	size_t size = 8;
+
+	pr_info("out-of-bounds in memset2\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	memset(ptr+7, 0, 2);
+	kfree(ptr);
+}
+
+static noinline void __init kmalloc_oob_memset_4(void)
+{
+	char *ptr;
+	size_t size = 8;
+
+	pr_info("out-of-bounds in memset4\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	memset(ptr+5, 0, 4);
+	kfree(ptr);
+}
+
+
+static noinline void __init kmalloc_oob_memset_8(void)
+{
+	char *ptr;
+	size_t size = 8;
+
+	pr_info("out-of-bounds in memset8\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	memset(ptr+1, 0, 8);
+	kfree(ptr);
+}
+
+static noinline void __init kmalloc_oob_memset_16(void)
+{
+	char *ptr;
+	size_t size = 16;
+
+	pr_info("out-of-bounds in memset16\n");
+	ptr = kmalloc(size, GFP_KERNEL);
+	if (!ptr) {
+		pr_err("Allocation failed\n");
+		return;
+	}
+
+	memset(ptr+1, 0, 16);
+	kfree(ptr);
+}
+
 static noinline void __init kmalloc_oob_in_memset(void)
 {
 	char *ptr;
@@ -264,6 +329,10 @@ static int __init kmalloc_tests_init(void)
 	kmalloc_oob_krealloc_less();
 	kmalloc_oob_16();
 	kmalloc_oob_in_memset();
+	kmalloc_oob_memset_2();
+	kmalloc_oob_memset_4();
+	kmalloc_oob_memset_8();
+	kmalloc_oob_memset_16();
 	kmalloc_uaf();
 	kmalloc_uaf_memset();
 	kmalloc_uaf2();
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

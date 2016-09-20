Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D46466B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:35:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o68so15890139qkf.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:35:44 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id e63si22451725qkd.174.2016.09.19.22.35.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 22:35:44 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/3] linux/mm.h: canonicalize macro PAGE_ALIGNED() definition
Message-ID: <57E0CA76.60905@zoho.com>
Date: Tue, 20 Sep 2016 13:34:46 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zijun_hu <zijun_hu@htc.com>

canonicalize macro PAGE_ALIGNED() definition

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 include/linux/mm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9..ec68186 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -126,7 +126,7 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
 
 /* test whether an address (unsigned long or pointer) is aligned to PAGE_SIZE */
-#define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)addr, PAGE_SIZE)
+#define PAGE_ALIGNED(addr)	IS_ALIGNED((unsigned long)(addr), PAGE_SIZE)
 
 /*
  * Linux kernel virtual memory manager primitives.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id B8F6B6B0253
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 06:42:54 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id j78so67300517lfb.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:54 -0800 (PST)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id dw8si8121843lbc.59.2016.02.27.03.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 03:42:53 -0800 (PST)
Received: by mail-lf0-x234.google.com with SMTP id m1so67586129lfg.0
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 03:42:53 -0800 (PST)
Subject: [PATCH 2/3] radix-tree tests: fix compilation
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Feb 2016 14:42:49 +0300
Message-ID: <145657336945.9016.11711393244395068180.stgit@zurg>
In-Reply-To: <145657336413.9016.2011291702664991604.stgit@zurg>
References: <145657336413.9016.2011291702664991604.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org

Couple GFP flags and empty header linux/init.h

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/testing/radix-tree/linux/gfp.h  |    2 ++
 tools/testing/radix-tree/linux/init.h |    0 
 2 files changed, 2 insertions(+)
 create mode 100644 tools/testing/radix-tree/linux/init.h

diff --git a/tools/testing/radix-tree/linux/gfp.h b/tools/testing/radix-tree/linux/gfp.h
index 01f1eabba119..0e37f7a760eb 100644
--- a/tools/testing/radix-tree/linux/gfp.h
+++ b/tools/testing/radix-tree/linux/gfp.h
@@ -4,5 +4,7 @@
 #define __GFP_BITS_SHIFT 22
 #define __GFP_BITS_MASK ((gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 #define __GFP_WAIT 1
+#define __GFP_ACCOUNT 0
+#define __GFP_NOWARN 0
 
 #endif
diff --git a/tools/testing/radix-tree/linux/init.h b/tools/testing/radix-tree/linux/init.h
new file mode 100644
index 000000000000..e69de29bb2d1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

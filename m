Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE8D900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:14:50 -0400 (EDT)
Received: by oihd6 with SMTP id d6so30834384oih.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:14:50 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v23si1652906oia.4.2015.06.04.06.14.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:14:50 -0700 (PDT)
Message-ID: <55704C4D.9070508@huawei.com>
Date: Thu, 4 Jun 2015 21:02:05 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 07/12] mm: introduce __GFP_MIRROR to allocate mirrored
 pages
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch introduces a new gfp flag called "__GFP_MIRROR", it is used to
allocate mirrored pages through buddy system.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/gfp.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 15928f0..89d0091 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
+#define ___GFP_MIRROR		0x2000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -95,13 +96,15 @@ struct vm_area_struct;
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
 
+#define __GFP_MIRROR	((__force gfp_t)___GFP_MIRROR)	/* Allocate mirrored memory */
+
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
  * allocations that simply cannot be supported (e.g. page tables).
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

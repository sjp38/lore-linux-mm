Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 91C7A6B006C
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:29 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so98860811pac.2
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:29 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id i8si3322777pdm.106.2015.02.03.09.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:28 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ7000SKIR3R350@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:27 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 01/19] compiler: introduce __alias(symbol) shortcut
Date: Tue, 03 Feb 2015 20:42:54 +0300
Message-id: <1422985392-28652-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

To be consistent with other compiler attributes
introduce __alias(symbol) macro expanding into
__attribute__((alias(#symbol)))

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/compiler-gcc.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index 02ae99e..cdf13ca 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -66,6 +66,7 @@
 #define __deprecated			__attribute__((deprecated))
 #define __packed			__attribute__((packed))
 #define __weak				__attribute__((weak))
+#define __alias(symbol)		__attribute__((alias(#symbol)))
 
 /*
  * it doesn't make sense on ARM (currently the only user of __naked) to trace
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

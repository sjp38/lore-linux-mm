Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9D96B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 05:36:21 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so3039690pac.32
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 02:36:21 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id vv8si1785617pab.117.2014.07.17.02.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 17 Jul 2014 02:36:20 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8U006HWO0CXS40@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 Jul 2014 10:36:12 +0100 (BST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] CMA: generalize CMA reserved area management functionality
 (fixup)
Date: Thu, 17 Jul 2014 11:36:07 +0200
Message-id: <1405589767-17513-1-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <53C78ED7.7030002@samsung.com>
References: <53C78ED7.7030002@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

MAX_CMA_AREAS is used by other subsystems (i.e. arch/arm/mm/dma-mapping.c),
so we need to provide correct definition even if CMA is disabled.
This patch fixes this issue.

Reported-by: Sylwester Nawrocki <s.nawrocki@samsung.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 include/linux/cma.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 9a18a2b1934c..c077635cad76 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -5,7 +5,11 @@
  * There is always at least global CMA area and a few optional
  * areas configured in kernel .config.
  */
+#ifdef CONFIG_CMA
 #define MAX_CMA_AREAS	(1 + CONFIG_CMA_AREAS)
+#else
+#define MAX_CMA_AREAS	(0)
+#endif
 
 struct cma;
 
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

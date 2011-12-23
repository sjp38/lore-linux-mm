Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E5BCB6B0074
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:10 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWN007L3PAMRU@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 23 Dec 2011 12:28:01 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN00K8RPAN36@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:59 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:32 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 13/14] common: DMA-mapping: add WRITE_COMBINE attribute
In-reply-to: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1324643253-3024-14-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

DMA_ATTR_WRITE_COMBINE specifies that writes to the mapping may be
buffered to improve performance. It will be used by the replacement for
ARM/ARV32 specific dma_alloc_writecombine() function.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/DMA-attributes.txt |   10 ++++++++++
 include/linux/dma-attrs.h        |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
index b768cc0..811a5d4 100644
--- a/Documentation/DMA-attributes.txt
+++ b/Documentation/DMA-attributes.txt
@@ -31,3 +31,13 @@ may be weakly ordered, that is that reads and writes may pass each other.
 Since it is optional for platforms to implement DMA_ATTR_WEAK_ORDERING,
 those that do not will simply ignore the attribute and exhibit default
 behavior.
+
+DMA_ATTR_WRITE_COMBINE
+----------------------
+
+DMA_ATTR_WRITE_COMBINE specifies that writes to the mapping may be
+buffered to improve performance.
+
+Since it is optional for platforms to implement DMA_ATTR_WRITE_COMBINE,
+those that do not will simply ignore the attribute and exhibit default
+behavior.
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index 71ad34e..ada61e1 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -13,6 +13,7 @@
 enum dma_attr {
 	DMA_ATTR_WRITE_BARRIER,
 	DMA_ATTR_WEAK_ORDERING,
+	DMA_ATTR_WRITE_COMBINE,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

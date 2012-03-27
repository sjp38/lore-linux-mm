Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 039BC6B00F6
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:43:31 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M1J00LUHQ4FLJ@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 27 Mar 2012 14:43:28 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1J008F3Q4CGS@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 27 Mar 2012 14:43:25 +0100 (BST)
Date: Tue, 27 Mar 2012 15:42:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv2 14/14] common: DMA-mapping: add NON-CONSISTENT attribute
In-reply-to: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332855768-32583-15-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1332855768-32583-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kevin Cernekee <cernekee@gmail.com>, Dezhong Diao <dediao@cisco.com>, Richard Kuo <rkuo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, Michal Simek <monstr@monstr.eu>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Paul Mundt <lethal@linux-sh.org>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

DMA_ATTR_NON_CONSISTENT lets the platform to choose to return either
consistent or non-consistent memory as it sees fit.  By using this API,
you are guaranteeing to the platform that you have all the correct and
necessary sync points for this memory in the driver should it choose to
return non-consistent memory.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 Documentation/DMA-attributes.txt |    9 +++++++++
 include/linux/dma-attrs.h        |    1 +
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
index 811a5d4..9120de2 100644
--- a/Documentation/DMA-attributes.txt
+++ b/Documentation/DMA-attributes.txt
@@ -41,3 +41,12 @@ buffered to improve performance.
 Since it is optional for platforms to implement DMA_ATTR_WRITE_COMBINE,
 those that do not will simply ignore the attribute and exhibit default
 behavior.
+
+DMA_ATTR_NON_CONSISTENT
+-----------------------
+
+DMA_ATTR_NON_CONSISTENT lets the platform to choose to return either
+consistent or non-consistent memory as it sees fit.  By using this API,
+you are guaranteeing to the platform that you have all the correct and
+necessary sync points for this memory in the driver should it choose to
+return non-consistent memory.
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index ada61e1..547ab56 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -14,6 +14,7 @@ enum dma_attr {
 	DMA_ATTR_WRITE_BARRIER,
 	DMA_ATTR_WEAK_ORDERING,
 	DMA_ATTR_WRITE_COMBINE,
+	DMA_ATTR_NON_CONSISTENT,
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

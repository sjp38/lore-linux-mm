Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B43228D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 09:18:53 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout2.samsung.com [203.254.224.25])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5700MGC6B6B8M0@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 22:18:52 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5700H2L6B4YS50@mmp1.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jun 2012 22:18:51 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH/RFC 0/2] ARM: DMA-mapping: new extensions for buffer sharing
 (part 2)
Date: Wed, 06 Jun 2012 15:17:35 +0200
Message-id: <1338988657-20770-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello,

This is a continuation of the dma-mapping extensions posted in the
following thread:
http://thread.gmane.org/gmane.linux.kernel.mm/78644

We noticed that some advanced buffer sharing use cases usually require
creating a dma mapping for the same memory buffer for more than one
device. Usually also such buffer is never touched with CPU, so the data
are processed by the devices.

>From the DMA-mapping perspective this requires to call one of the
dma_map_{page,single,sg} function for the given memory buffer a few
times, for each of the devices. Each dma_map_* call performs CPU cache
synchronization, what might be a time consuming operation, especially
when the buffers are large. We would like to avoid any useless and time
consuming operations, so that was the main reason for introducing
another attribute for DMA-mapping subsystem: DMA_ATTR_SKIP_CPU_SYNC,
which lets dma-mapping core to skip CPU cache synchronization in certain
cases.

The proposed patches have been generated on top of the ARM DMA-mapping
redesign patch series on Linux v3.4-rc7. They are also available on the
following GIT branch:

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc7-arm-dma-v10-ext

with all require patches on top of vanilla v3.4-rc7 kernel. I will
resend them rebased onto v3.5-rc1 soon.

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (2):
  common: DMA-mapping: add DMA_ATTR_SKIP_CPU_SYNC attribute
  ARM: dma-mapping: add support for DMA_ATTR_SKIP_CPU_SYNC attribute

 Documentation/DMA-attributes.txt |   24 ++++++++++++++++++++++++
 arch/arm/mm/dma-mapping.c        |   20 +++++++++++---------
 include/linux/dma-attrs.h        |    1 +
 3 files changed, 36 insertions(+), 9 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

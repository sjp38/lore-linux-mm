Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 098976B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 02:10:37 -0400 (EDT)
From: Hiroshi DOYU <hdoyu@nvidia.com>
Subject: [RFC 0/2] dma-mapping: Introduce new IOVA API with address specified
Date: Fri, 18 May 2012 09:10:25 +0300
Message-ID: <1337321427-27748-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hdoyu@nvidia.com, m.szyprowski@samsung.com, linaro-mm-sig@lists.linaro.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-tegra@vger.kernel.org

Hello,

The following patchset is our enhancement for the upstream DMA mapping
API(v9), where new IOVA API is introduced with the version of IOVA
address specified. The current upstream DMA mapping API cannot specify
any specific IOVA address at allocation. We need to specify IOVA
address. This is necessary because some HWAs requre some specific
address, for example,  AVP vector and also some data buffer alignement
can improve better performance from H/W constraints POV.

Hiroshi DOYU (2):
  dma-mapping: Export arm_iommu_{alloc,free}_iova() functions
  dma-mapping: Enable IOVA mapping with specific address

 arch/arm/include/asm/dma-iommu.h   |   31 ++++++
 arch/arm/include/asm/dma-mapping.h |    1 +
 arch/arm/mm/dma-mapping.c          |  181 +++++++++++++++++++++++++++++-------
 3 files changed, 180 insertions(+), 33 deletions(-)

-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

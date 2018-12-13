Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB2E8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 06:25:13 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id 129so449343wmy.7
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 03:25:13 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y71si1335030wme.122.2018.12.13.03.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 03:25:11 -0800 (PST)
Date: Thu, 13 Dec 2018 12:25:11 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20181213112511.GA4574@lst.de>
References: <1ecb7692-f3fb-a246-91f9-2db1b9496305@xenosoft.de> <6c997c03-e072-97a9-8ae0-38a4363df919@xenosoft.de> <4cfb3f26-74e1-db01-b014-759f188bb5a6@xenosoft.de> <82879d3f-83de-6438-c1d6-49c571dcb671@xenosoft.de> <20181212141556.GA4801@lst.de> <2242B4B2-6311-492E-BFF9-6740E36EC6D4@xenosoft.de> <84558d7f-5a7f-5219-0c3a-045e6b4c494f@xenosoft.de> <20181213091021.GA2106@lst.de> <835bd119-081e-a5ea-1899-189d439c83d6@xenosoft.de> <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <76bc684a-b4d2-1d26-f18d-f5c9ba65978c@xenosoft.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>, linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>, linuxppc-dev@lists.ozlabs.org

On Thu, Dec 13, 2018 at 12:19:26PM +0100, Christian Zigotzky wrote:
> I tried it again but I get the following error message:
>
> MODPOST vmlinux.o
> arch/powerpc/kernel/dma-iommu.o: In function `.dma_iommu_get_required_mask':
> (.text+0x274): undefined reference to `.dma_direct_get_required_mask'
> make: *** [vmlinux] Error 1

Sorry, you need this one liner before all the patches posted last time:

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d8819e3a1eb1..7e78c2798f2f 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -154,6 +154,7 @@ config PPC
 	select CLONE_BACKWARDS
 	select DCACHE_WORD_ACCESS		if PPC64 && CPU_LITTLE_ENDIAN
 	select DYNAMIC_FTRACE			if FUNCTION_TRACER
+	select DMA_DIRECT_OPS
 	select EDAC_ATOMIC_SCRUB
 	select EDAC_SUPPORT
 	select GENERIC_ATOMIC64			if PPC32

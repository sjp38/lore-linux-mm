Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2F7FC6B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 03:52:59 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M3U004SALV22Z20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 08:52:14 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3U00AGRLW6KB@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 08:52:55 +0100 (BST)
Date: Fri, 11 May 2012 09:52:53 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv9 10/10] ARM: dma-mapping: add support for IOMMU mapper
In-reply-to: 
 <CAP=VYLr=NeGvppR4ONpnRh=gjCSPdKxYj1HYh_FvadAeUzcbBQ@mail.gmail.com>
Message-id: <02e301cd2f4b$11e02f90$35a08eb0$%szyprowski@samsung.com>
Content-language: pl
References: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
 <1334756652-30830-11-git-send-email-m.szyprowski@samsung.com>
 <CAP=VYLr=NeGvppR4ONpnRh=gjCSPdKxYj1HYh_FvadAeUzcbBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Paul Gortmaker' <paul.gortmaker@windriver.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, linux-next@vger.kernel.org

Hello,

On Friday, May 11, 2012 4:09 AM Paul Gortmaker wrote:

> On Wed, Apr 18, 2012 at 9:44 AM, Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
> > This patch add a complete implementation of DMA-mapping API for
> > devices which have IOMMU support.
> 
> Hi Marek,
> 
> It looks like this patch breaks no-MMU builds on ARM, at least
> according to git bisect.  Here is a link to a linux-next failure:
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/6291233/
> 
> arch/arm/mm/dma-mapping.c:726:42: error: 'pgprot_kernel' undeclared
> (first use in this function)
> make[2]: *** [arch/arm/mm/dma-mapping.o] Error 1
> 
> Please have a look, thanks.

Thanks for reporting this issue, I will send a fix in a minute.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

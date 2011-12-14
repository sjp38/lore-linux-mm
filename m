Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6E7C96B02D8
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 07:37:17 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LW700BLH1Q2V450@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 14 Dec 2011 12:37:14 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LW7001MW1Q206@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 14 Dec 2011 12:37:14 +0000 (GMT)
Date: Wed, 14 Dec 2011 13:37:07 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 6/8] common: dma-mapping: change alloc/free_coherent method
 to more generic alloc/free_attrs
In-reply-to: <20111212094559.e4af7c0ab6633de400487fde@canb.auug.org.au>
Message-id: <040501ccba5d$1821e0a0$4865a1e0$%szyprowski@samsung.com>
Content-language: pl
References: <1323448798-18184-1-git-send-email-m.szyprowski@samsung.com>
 <1323448798-18184-7-git-send-email-m.szyprowski@samsung.com>
 <20111212094559.e4af7c0ab6633de400487fde@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Stephen Rothwell' <sfr@canb.auug.org.au>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Shariq Hasnain' <shariq.hasnain@linaro.org>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>

Hello,

On Sunday, December 11, 2011 11:46 PM Stephen Rothwell wrote:

> On Fri, 09 Dec 2011 17:39:56 +0100 Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> >
> > Introduce new alloc/free/mmap methods that take attributes argument.
> > alloc/free_coherent can be implemented on top of the new alloc/free
> > calls with NULL attributes. dma_alloc_non_coherent can be implemented
> > using DMA_ATTR_NONCOHERENT attribute, dma_alloc_writecombine can also
> > use separate DMA_ATTR_WRITECOMBINE attribute. This way the drivers will
> > get more generic, platform independent way of allocating dma memory
> > buffers with specific parameters.
> >
> > One more attribute can be usefull: DMA_ATTR_NOKERNELVADDR. Buffers with
> > such attribute will not have valid kernel virtual address. They might be
> > usefull for drivers that only exports the DMA buffers to userspace (like
> > for example V4L2 or ALSA).
> >
> > mmap method is introduced to let the drivers create a user space mapping
> > for a DMA buffer in generic, architecture independent way.
> >
> > TODO: update all dma_map_ops clients for all architectures
> 
> To give everyone some chance, you should come up with a transition plan
> rather than this "attempt to fix everyone at once" approach.  You could
> (for example) just add the new methods now and only remove them in the
> following merge window when all the architectures have had a chance to
> migrate.
> 
> And, in fact, (as I presume you know) this patch just breaks everyone
> with no attempt to cope.

Yes, I know that. Next version will include correct fix for this issue as
well as adjustments for other architectures. I was asked to post a current
version of DMA-mapping & IOMMU integration patch rebased on the latest kernel
and I wanted to this before going for holidays to let others to work with the
latest version.

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

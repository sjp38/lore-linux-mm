Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3371B6B0082
	for <linux-mm@kvack.org>; Mon, 28 May 2012 04:19:45 -0400 (EDT)
Received: from euspt1 (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Q001E04I1CE40@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 28 May 2012 09:20:25 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Q0027D4GU8J@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 28 May 2012 09:19:43 +0100 (BST)
Date: Mon, 28 May 2012 10:19:39 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv2 3/4] mm: vmalloc: add VM_DMA flag to indicate areas used
 by dma-mapping framework
In-reply-to: 
 <CAHGf_=qmBMFfV=UhXFtepO8styaQonfBA0E0+FO0qSi7RLfJFA@mail.gmail.com>
Message-id: <001d01cd3caa$a05d0510$e1170f30$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-4-git-send-email-m.szyprowski@samsung.com>
 <4FBB3B41.8010102@kernel.org>
 <01e501cd39a8$67f34ea0$37d9ebe0$%szyprowski@samsung.com>
 <20120524122854.GD11860@linux-sh.org>
 <CAHGf_=qmBMFfV=UhXFtepO8styaQonfBA0E0+FO0qSi7RLfJFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>, 'Paul Mundt' <lethal@linux-sh.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

Hello,

On Sunday, May 27, 2012 2:35 PM KOSAKI Motohiro wrote:

> On Thu, May 24, 2012 at 8:28 AM, Paul Mundt <lethal@linux-sh.org> wrote:
> > On Thu, May 24, 2012 at 02:26:12PM +0200, Marek Szyprowski wrote:
> >> On Tuesday, May 22, 2012 9:08 AM Minchan Kim wrote:
> >> > Hmm, VM_DMA would become generic flag?
> >> > AFAIU, maybe VM_DMA would be used only on ARM arch.
> >>
> >> Right now yes, it will be used only on ARM architecture, but maybe other architecture will
> >> start using it once it is available.
> >>
> > There's very little about the code in question that is ARM-specific to
> > begin with. I plan to adopt similar changes on SH once the work has
> > settled one way or the other, so we'll probably use the VMA flag there,
> > too.
> 
> I don't think VM_DMA is good idea because x86_64 has two dma zones. x86 unaware
> patches make no sense.

I see no problems to add VM_DMA64 later if x86_64 starts using vmalloc areas for creating 
kernel mappings for the dma buffers (I assume that there are 2 dma zones: one 32bit and one
64bit). Right now x86 and x86_64 don't use vmalloc areas for dma buffers, so I hardly see
how this patch can be considered as 'x86 unaware'.

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

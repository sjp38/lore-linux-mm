Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E8FCF6B006C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:14:15 -0400 (EDT)
Date: Tue, 29 May 2012 11:07:14 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv2 3/4] mm: vmalloc: add VM_DMA flag to indicate areas
 used by dma-mapping framework
Message-ID: <20120529150714.GA8293@phenom.dumpdata.com>
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-4-git-send-email-m.szyprowski@samsung.com>
 <4FBB3B41.8010102@kernel.org>
 <01e501cd39a8$67f34ea0$37d9ebe0$%szyprowski@samsung.com>
 <20120524122854.GD11860@linux-sh.org>
 <CAHGf_=qmBMFfV=UhXFtepO8styaQonfBA0E0+FO0qSi7RLfJFA@mail.gmail.com>
 <001d01cd3caa$a05d0510$e1170f30$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001d01cd3caa$a05d0510$e1170f30$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>, 'Paul Mundt' <lethal@linux-sh.org>, 'Minchan Kim' <minchan@kernel.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

On Mon, May 28, 2012 at 10:19:39AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On Sunday, May 27, 2012 2:35 PM KOSAKI Motohiro wrote:
> 
> > On Thu, May 24, 2012 at 8:28 AM, Paul Mundt <lethal@linux-sh.org> wrote:
> > > On Thu, May 24, 2012 at 02:26:12PM +0200, Marek Szyprowski wrote:
> > >> On Tuesday, May 22, 2012 9:08 AM Minchan Kim wrote:
> > >> > Hmm, VM_DMA would become generic flag?
> > >> > AFAIU, maybe VM_DMA would be used only on ARM arch.
> > >>
> > >> Right now yes, it will be used only on ARM architecture, but maybe other architecture will
> > >> start using it once it is available.
> > >>
> > > There's very little about the code in question that is ARM-specific to
> > > begin with. I plan to adopt similar changes on SH once the work has
> > > settled one way or the other, so we'll probably use the VMA flag there,
> > > too.
> > 
> > I don't think VM_DMA is good idea because x86_64 has two dma zones. x86 unaware
> > patches make no sense.
> 
> I see no problems to add VM_DMA64 later if x86_64 starts using vmalloc areas for creating 
> kernel mappings for the dma buffers (I assume that there are 2 dma zones: one 32bit and one
> 64bit). Right now x86 and x86_64 don't use vmalloc areas for dma buffers, so I hardly see
> how this patch can be considered as 'x86 unaware'.

Well they do - kind off. It is usually done by calling vmalloc_32 and then using
the DMA API on top of those pages (or sometimes the non-portable virt_to_phys macro).

Introducing this and replacing the vmalloc_32 with this seems like a nice step in making
those device drivers APIs more portable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

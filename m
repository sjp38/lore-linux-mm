Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 121276B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 08:29:22 -0400 (EDT)
Date: Thu, 24 May 2012 21:28:54 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCHv2 3/4] mm: vmalloc: add VM_DMA flag to indicate areas
 used by dma-mapping framework
Message-ID: <20120524122854.GD11860@linux-sh.org>
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-4-git-send-email-m.szyprowski@samsung.com>
 <4FBB3B41.8010102@kernel.org>
 <01e501cd39a8$67f34ea0$37d9ebe0$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01e501cd39a8$67f34ea0$37d9ebe0$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>, 'Nick Piggin' <npiggin@gmail.com>

On Thu, May 24, 2012 at 02:26:12PM +0200, Marek Szyprowski wrote:
> On Tuesday, May 22, 2012 9:08 AM Minchan Kim wrote:
> > Hmm, VM_DMA would become generic flag?
> > AFAIU, maybe VM_DMA would be used only on ARM arch.
> 
> Right now yes, it will be used only on ARM architecture, but maybe other architecture will
> start using it once it is available.
> 
There's very little about the code in question that is ARM-specific to
begin with. I plan to adopt similar changes on SH once the work has
settled one way or the other, so we'll probably use the VMA flag there,
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

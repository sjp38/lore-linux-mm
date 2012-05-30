Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CF8CF6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 03:15:58 -0400 (EDT)
Received: from euspt1 (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4T004DVQVNNP20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 30 May 2012 08:16:35 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4T004BFQUKK1@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 30 May 2012 08:15:57 +0100 (BST)
Date: Wed, 30 May 2012 09:15:53 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv2 4/4] ARM: dma-mapping: remove custom consistent dma region
In-reply-to: <4FC5659D.6040805@gmail.com>
Message-id: <019401cd3e34$0c6af4d0$2540de70$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com>
 <1337252085-22039-5-git-send-email-m.szyprowski@samsung.com>
 <4FC5659D.6040805@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>

Hello,

On Wednesday, May 30, 2012 2:11 AM KOSAKI Motohiro wrote:

> >   static void *
> >   __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
> >   	const void *caller)
> >   {
> > -	struct arm_vmregion *c;
> > -	size_t align;
> > -	int bit;
> > +	struct vm_struct *area;
> > +	unsigned long addr;
> >
> > -	if (!consistent_pte) {
> > -		printk(KERN_ERR "%s: not initialised\n", __func__);
> > +	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
> 
> In this patch, VM_DMA is only used here. So, is this no effect?

I introduced it mainly to let user know which areas have been allocated by the dma-mapping api.

I also plan to add a check suggested by Minchan Kim in __dma_free_remap() if the vmalloc area
have been in fact allocated with VM_DMA set. 

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

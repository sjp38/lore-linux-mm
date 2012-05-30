Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id ACC046B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 03:22:58 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so3200219qcs.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 00:22:57 -0700 (PDT)
Message-ID: <4FC5CACD.6000105@gmail.com>
Date: Wed, 30 May 2012 03:22:53 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 4/4] ARM: dma-mapping: remove custom consistent dma
 region
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com> <1337252085-22039-5-git-send-email-m.szyprowski@samsung.com> <4FC5659D.6040805@gmail.com> <019401cd3e34$0c6af4d0$2540de70$%szyprowski@samsung.com>
In-Reply-To: <019401cd3e34$0c6af4d0$2540de70$%szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'KOSAKI Motohiro' <kosaki.motohiro@gmail.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>

(5/30/12 3:15 AM), Marek Szyprowski wrote:
> Hello,
>
> On Wednesday, May 30, 2012 2:11 AM KOSAKI Motohiro wrote:
>
>>>    static void *
>>>    __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
>>>    	const void *caller)
>>>    {
>>> -	struct arm_vmregion *c;
>>> -	size_t align;
>>> -	int bit;
>>> +	struct vm_struct *area;
>>> +	unsigned long addr;
>>>
>>> -	if (!consistent_pte) {
>>> -		printk(KERN_ERR "%s: not initialised\n", __func__);
>>> +	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);
>>
>> In this patch, VM_DMA is only used here. So, is this no effect?
>
> I introduced it mainly to let user know which areas have been allocated by the dma-mapping api.

vma->flags are limited resource, it has only 32 (or 64) bits. Please don't use it for such unimportant
thing.


> I also plan to add a check suggested by Minchan Kim in __dma_free_remap() if the vmalloc area
> have been in fact allocated with VM_DMA set.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

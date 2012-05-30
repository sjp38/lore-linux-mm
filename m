Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 21DAA6B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 20:11:09 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1936816qab.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 17:11:08 -0700 (PDT)
Message-ID: <4FC5659D.6040805@gmail.com>
Date: Tue, 29 May 2012 20:11:09 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 4/4] ARM: dma-mapping: remove custom consistent dma
 region
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com> <1337252085-22039-5-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1337252085-22039-5-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, kosaki.motohiro@gmail.com

>   static void *
>   __dma_alloc_remap(struct page *page, size_t size, gfp_t gfp, pgprot_t prot,
>   	const void *caller)
>   {
> -	struct arm_vmregion *c;
> -	size_t align;
> -	int bit;
> +	struct vm_struct *area;
> +	unsigned long addr;
> 
> -	if (!consistent_pte) {
> -		printk(KERN_ERR "%s: not initialised\n", __func__);
> +	area = get_vm_area_caller(size, VM_DMA | VM_USERMAP, caller);

In this patch, VM_DMA is only used here. So, is this no effect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

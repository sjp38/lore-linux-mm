Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 649686B004D
	for <linux-mm@kvack.org>; Tue, 22 May 2012 03:01:12 -0400 (EDT)
Message-ID: <4FBB39BA.3000601@kernel.org>
Date: Tue, 22 May 2012 16:01:14 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCHv2 2/4] mm: vmalloc: export find_vm_area() function
References: <1337252085-22039-1-git-send-email-m.szyprowski@samsung.com> <1337252085-22039-3-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1337252085-22039-3-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

On 05/17/2012 07:54 PM, Marek Szyprowski wrote:

> find_vm_area() function is usefull for other core subsystems (like
> dma-mapping) to get access to vm_area internals.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>


We can't know how you want to use this function.
It would be better to fold this patch into [4/4].

> ---
>  include/linux/vmalloc.h |    1 +
>  mm/vmalloc.c            |   10 +++++++++-
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 2e28f4d..6071e91 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -93,6 +93,7 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
>  					unsigned long start, unsigned long end,
>  					const void *caller);
>  extern struct vm_struct *remove_vm_area(const void *addr);
> +extern struct vm_struct *find_vm_area(const void *addr);
>  
>  extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
>  			struct page ***pages);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 8bc7f3ef..8cb7f22 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1402,7 +1402,15 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
>  						-1, GFP_KERNEL, caller);
>  }
>  
> -static struct vm_struct *find_vm_area(const void *addr)
> +/**
> + *	find_vm_area  -  find a continuous kernel virtual area
> + *	@addr:		base address
> + *
> + *	Search for the kernel VM area starting at @addr, and return it.
> + *	It is up to the caller to do all required locking to keep the returned
> + *	pointer valid.
> + */
> +struct vm_struct *find_vm_area(const void *addr)
>  {
>  	struct vmap_area *va;
>  



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

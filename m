Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 73C896B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:54:33 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id q200so35113467ykb.8
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:54:33 -0800 (PST)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
        by mx.google.com with ESMTPS id h35si24520947yhq.140.2014.02.18.14.54.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:54:32 -0800 (PST)
Received: by mail-qg0-f46.google.com with SMTP id e89so8018056qgf.5
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:54:32 -0800 (PST)
Date: Tue, 18 Feb 2014 17:54:30 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCHv4 1/2] mm/memblock: add memblock_get_current_limit
In-Reply-To: <1392761733-32628-2-git-send-email-lauraa@codeaurora.org>
Message-ID: <alpine.LFD.2.11.1402181754030.17677@knanqh.ubzr>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>

On Tue, 18 Feb 2014, Laura Abbott wrote:

> Apart from setting the limit of memblock, it's also useful to be able
> to get the limit to avoid recalculating it every time. Add the function
> to do so.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Acked-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Acked-by: Nicolas Pitre <nico@linaro.org>


> ---
>  include/linux/memblock.h |    2 ++
>  mm/memblock.c            |    5 +++++
>  2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 1ef6636..8a20a51 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -252,6 +252,8 @@ static inline void memblock_dump_all(void)
>  void memblock_set_current_limit(phys_addr_t limit);
>  
>  
> +phys_addr_t memblock_get_current_limit(void);
> +
>  /*
>   * pfn conversion functions
>   *
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 39a31e7..7fe5354 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1407,6 +1407,11 @@ void __init_memblock memblock_set_current_limit(phys_addr_t limit)
>  	memblock.current_limit = limit;
>  }
>  
> +phys_addr_t __init_memblock memblock_get_current_limit(void)
> +{
> +	return memblock.current_limit;
> +}
> +
>  static void __init_memblock memblock_dump(struct memblock_type *type, char *name)
>  {
>  	unsigned long long base, size;
> -- 
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> hosted by The Linux Foundation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

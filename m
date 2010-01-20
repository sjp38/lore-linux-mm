Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 081AE6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 08:50:18 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 16so41804fgg.8
        for <linux-mm@kvack.org>; Wed, 20 Jan 2010 05:50:17 -0800 (PST)
Message-ID: <4B570A15.8040601@gmail.com>
Date: Wed, 20 Jan 2010 14:50:13 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/1] bootmem: move big allocations behing 4G
References: <1263855390-32497-1-git-send-email-jslaby@suse.cz> <20100119143355.GB7932@cmpxchg.org>
In-Reply-To: <20100119143355.GB7932@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On 01/19/2010 03:33 PM, Johannes Weiner wrote:
> --- a/include/linux/bootmem.h
> +++ b/include/linux/bootmem.h
> @@ -96,20 +96,26 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
>  				      unsigned long align,
>  				      unsigned long goal);
>  
> +#ifdef MAX_DMA32_PFN
> +#define BOOTMEM_DEFAULT_GOAL	(__pa(MAX_DMA32_PFN << PAGE_SHIFT))
> +#else
> +#define BOOTMEM_DEFAULT_GOAL	MAX_DMA_ADDRESS

I just noticed this should write:
#define BOOTMEM_DEFAULT_GOAL   __pa(MAX_DMA_ADDRESS)

> +#endif
> +
>  #define alloc_bootmem(x) \
> -	__alloc_bootmem(x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
> +	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_DEFAULT_GOAL)


-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

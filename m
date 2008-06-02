Message-ID: <48440E15.4080008@goop.org>
Date: Mon, 02 Jun 2008 16:13:25 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] mem_map/max_mapnr are specific to the FLATMEM memory
 model
References: <20080410103306.GA29831@shadowen.org> <1207824082.0@pinky>
In-Reply-To: <1207824082.0@pinky>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@saeurebad.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> mem_map and max_mapnr are variables used in the FLATMEM memory model
> only.  Ensure they are only defined when that memory model is enabled.
>   

Is this series queued to be applied?

BTW, how does max_mapnr differ from x86-64's end_pfn?

> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> ---
>  mm/memory.c |    3 +--
>   

I think you need to fix the declaration in linux/mm.h as well.

>  1 files changed, 1 insertions(+), 2 deletions(-)
> diff --git a/mm/memory.c b/mm/memory.c
> index 0d14d1e..091324e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -61,8 +61,7 @@
>  #include <linux/swapops.h>
>  #include <linux/elf.h>
>  
> -#ifndef CONFIG_NEED_MULTIPLE_NODES
> -/* use the per-pgdat data instead for discontigmem - mbligh */
> +#ifdef CONFIG_FLATMEM
>  unsigned long max_mapnr;
>  struct page *mem_map;
>  
>   

Thanks,
    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

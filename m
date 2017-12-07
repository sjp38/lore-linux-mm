Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7F96B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 05:38:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g80so3775966wrd.17
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 02:38:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si3748352wrg.510.2017.12.07.02.38.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 02:38:08 -0800 (PST)
Date: Thu, 7 Dec 2017 11:38:07 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: memory_hotplug: remove second __nr_to_section in
 register_page_bootmem_info_section()
Message-ID: <20171207103807.GF20234@dhcp22.suse.cz>
References: <20171207102914.GA12396@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207102914.GA12396@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz

On Thu 07-12-17 11:29:14, Oscar Salvador wrote:
> In register_page_bootmem_info_section() we call __nr_to_section() in order to
> get the mem_section struct at the beginning of the function.
> Since we already got it, there is no need for a second call to __nr_to_section().
> 
> Signed-off-by: Oscar Salvador <osalvador@techadventures.net>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 7452a53b027f..262bfd26baf9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -184,7 +184,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
>  	for (i = 0; i < mapsize; i++, page++)
>  		get_page_bootmem(section_nr, page, SECTION_INFO);
>  
> -	usemap = __nr_to_section(section_nr)->pageblock_flags;
> +	usemap = ms->pageblock_flags;
>  	page = virt_to_page(usemap);
>  
>  	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
> @@ -207,7 +207,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
>  
>  	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
>  
> -	usemap = __nr_to_section(section_nr)->pageblock_flags;
> +	usemap = ms->pageblock_flags;
>  	page = virt_to_page(usemap);
>  
>  	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

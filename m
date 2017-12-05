Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A27F6B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:44:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k104so229656wrc.19
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:44:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si395352edd.36.2017.12.05.06.44.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 06:44:25 -0800 (PST)
Date: Tue, 5 Dec 2017 15:44:22 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: memory_hotplug: Remove unnecesary check from
 register_page_bootmem_info_section()
Message-ID: <20171205144422.ecg5k4n6zhyjm7ks@dhcp22.suse.cz>
References: <20171205143422.GA31458@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205143422.GA31458@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vbabka@suse.cz

On Tue 05-12-17 15:34:22, Oscar Salvador wrote:
> When we call register_page_bootmem_info_section() having CONFIG_SPARSEMEM_VMEMMAP enabled,
> we check if the pfn is valid.
> This check is redundant as we already checked this in register_page_bootmem_info_node()
> before calling register_page_bootmem_info_section(), so let's get rid of it.

there is quite a lot of legacy and confused code in memory hotplug. Some
of it is really subtle but this one is really straightforward

> Signed-off-by: Oscar Salvador <osalvador@techadventures.net>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d0856ab2f28d..7452a53b027f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -200,9 +200,6 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
>  	struct mem_section *ms;
>  	struct page *page, *memmap;
>  
> -	if (!pfn_valid(start_pfn))
> -		return;
> -
>  	section_nr = pfn_to_section_nr(start_pfn);
>  	ms = __nr_to_section(section_nr);
>  
> -- 
> 2.13.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5DA86B02A3
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 10:15:17 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so48226196wjb.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 07:15:17 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ja7si18818278wjb.23.2016.12.19.07.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 07:15:16 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so19234178wme.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 07:15:16 -0800 (PST)
Date: Mon, 19 Dec 2016 16:15:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 1/2] mm/memblock.c: trivial code refine in
 memblock_is_region_memory()
Message-ID: <20161219151514.GB5175@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 18-12-16 14:47:49, Wei Yang wrote:
> The base address is already guaranteed to be in the region by
> memblock_search().

First of all the way how the check is removed is the worst possible...
Apart from that it is really not clear to me why checking the base
is not needed. You are mentioning memblock_search but what about other
callers? adjust_range_page_size_mask e.g...

You also didn't mention what is the motivation of this change? What will
work better or why it makes sense in general?

Also this seems to be a general purpose function so it should better
be robust.

> This patch removes the check on base.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Without a proper justification and with the horrible way how it is done
Nacked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memblock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7608bc3..cd85303 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1615,7 +1615,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
>  
>  	if (idx == -1)
>  		return 0;
> -	return memblock.memory.regions[idx].base <= base &&
> +	return /* memblock.memory.regions[idx].base <= base && */
>  		(memblock.memory.regions[idx].base +
>  		 memblock.memory.regions[idx].size) >= end;
>  }
> -- 
> 2.5.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

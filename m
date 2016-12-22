Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A82C96B03E7
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:06:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so34830753wmw.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 01:06:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si783136wjj.194.2016.12.22.01.06.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 01:06:51 -0800 (PST)
Date: Thu, 22 Dec 2016 10:06:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 1/2] mm/memblock.c: trivial code refine in
 memblock_is_region_memory()
Message-ID: <20161222090648.GB6048@dhcp22.suse.cz>
References: <1482363033-24754-1-git-send-email-richard.weiyang@gmail.com>
 <1482363033-24754-2-git-send-email-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1482363033-24754-2-git-send-email-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-12-16 23:30:32, Wei Yang wrote:
> memblock_is_region_memory() invoke memblock_search() to see whether the
> base address is in the memory region. If it fails, idx would be -1. Then,
> it returns 0.
> 
> If the memblock_search() returns a valid index, it means the base address
> is guaranteed to be in the range memblock.memory.regions[idx]. Because of
> this, it is not necessary to check the base again.
> 
> This patch removes the check on "base".

OK, the patch looks correct. I doubt it makes any real difference but I
do not see it being harmful.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memblock.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7608bc3..4929e06 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1615,8 +1615,7 @@ int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size
>  
>  	if (idx == -1)
>  		return 0;
> -	return memblock.memory.regions[idx].base <= base &&
> -		(memblock.memory.regions[idx].base +
> +	return (memblock.memory.regions[idx].base +
>  		 memblock.memory.regions[idx].size) >= end;
>  }
>  
> -- 
> 2.5.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

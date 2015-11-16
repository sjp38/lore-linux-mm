Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45F566B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:41:53 -0500 (EST)
Received: by wmvv187 with SMTP id v187so174212514wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:41:52 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id u185si25496759wmu.20.2015.11.16.04.41.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:41:52 -0800 (PST)
Received: by wmec201 with SMTP id c201so25635497wme.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:41:51 -0800 (PST)
Date: Mon, 16 Nov 2015 13:41:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/7] mm/memblock: memblock_is_memory/reserved can be
 boolean
Message-ID: <20151116124150.GD14116@dhcp22.suse.cz>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-4-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447656686-4851-4-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-11-15 14:51:22, Yaowei Bai wrote:
> This patch makes memblock_is_memory/reserved return bool to improve
> readability due to this particular function only using either
> one or zero as its return value.
> 
> No functional change.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memblock.h | 4 ++--
>  mm/memblock.c            | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 24daf8f..a25cce94 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -318,9 +318,9 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
>  phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> -int memblock_is_memory(phys_addr_t addr);
> +bool memblock_is_memory(phys_addr_t addr);
>  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
> -int memblock_is_reserved(phys_addr_t addr);
> +bool memblock_is_reserved(phys_addr_t addr);
>  bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
>  
>  extern void __memblock_dump_all(void);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d300f13..1ab7b9e 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1509,12 +1509,12 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>  	return -1;
>  }
>  
> -int __init memblock_is_reserved(phys_addr_t addr)
> +bool __init memblock_is_reserved(phys_addr_t addr)
>  {
>  	return memblock_search(&memblock.reserved, addr) != -1;
>  }
>  
> -int __init_memblock memblock_is_memory(phys_addr_t addr)
> +bool __init_memblock memblock_is_memory(phys_addr_t addr)
>  {
>  	return memblock_search(&memblock.memory, addr) != -1;
>  }
> -- 
> 1.9.1
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

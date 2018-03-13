Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53A036B0007
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:06:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c16so8040932pgv.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:06:44 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id g23si56665pfb.87.2018.03.13.05.06.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 05:06:43 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: OK to merge via powerpc? (was Re: [PATCH 05/14] mm: make memblock_alloc_base_nid non-static)
In-Reply-To: <20180213150824.27689-6-npiggin@gmail.com>
References: <20180213150824.27689-1-npiggin@gmail.com> <20180213150824.27689-6-npiggin@gmail.com>
Date: Tue, 13 Mar 2018 23:06:35 +1100
Message-ID: <873714goxg.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, pasha.tatashin@oracle.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, npiggin@gmail.com, baiyaowei@cmss.chinamobile.com, bob.picco@oracle.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org

Anyone object to us merging the following patch via the powerpc tree?

Full series is here if anyone's interested:
  http://patchwork.ozlabs.org/project/linuxppc-dev/list/?series=28377&state=*

cheers

Nicholas Piggin <npiggin@gmail.com> writes:
> This will be used by powerpc to allocate per-cpu stacks and other
> data structures node-local where possible.
>
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  include/linux/memblock.h | 5 ++++-
>  mm/memblock.c            | 2 +-
>  2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 8be5077efb5f..8cab51398705 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -316,9 +316,12 @@ static inline bool memblock_bottom_up(void)
>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
>  
> -phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
> +phys_addr_t memblock_alloc_range(phys_addr_t size, phys_addr_t align,
>  					phys_addr_t start, phys_addr_t end,
>  					ulong flags);
> +phys_addr_t memblock_alloc_base_nid(phys_addr_t size,
> +					phys_addr_t align, phys_addr_t max_addr,
> +					int nid, ulong flags);
>  phys_addr_t memblock_alloc_base(phys_addr_t size, phys_addr_t align,
>  				phys_addr_t max_addr);
>  phys_addr_t __memblock_alloc_base(phys_addr_t size, phys_addr_t align,
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 5a9ca2a1751b..cea2af494da0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1190,7 +1190,7 @@ phys_addr_t __init memblock_alloc_range(phys_addr_t size, phys_addr_t align,
>  					flags);
>  }
>  
> -static phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
> +phys_addr_t __init memblock_alloc_base_nid(phys_addr_t size,
>  					phys_addr_t align, phys_addr_t max_addr,
>  					int nid, ulong flags)
>  {
> -- 
> 2.16.1

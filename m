Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 322B86B0038
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 13:20:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d79so9676593pfe.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 10:20:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l62si21135840pgd.48.2017.04.05.10.20.50
        for <linux-mm@kvack.org>;
        Wed, 05 Apr 2017 10:20:51 -0700 (PDT)
Date: Wed, 5 Apr 2017 18:20:43 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v35 02/14] memblock: add memblock_cap_memory_range()
Message-ID: <20170405172043.GA2752@e104818-lin.cambridge.arm.com>
References: <20170403022139.12383-1-takahiro.akashi@linaro.org>
 <20170403022355.12463-2-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403022355.12463-2-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>, will.deacon@arm.com, mark.rutland@arm.com, panand@redhat.com, ard.biesheuvel@linaro.org, geoff@infradead.org, dwmw2@infradead.org, kexec@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, bauerman@linux.vnet.ibm.com, sgoel@codeaurora.org, dyoung@redhat.com, linux-arm-kernel@lists.infradead.org

On Mon, Apr 03, 2017 at 11:23:55AM +0900, AKASHI Takahiro wrote:
> Add memblock_cap_memory_range() which will remove all the memblock regions
> except the memory range specified in the arguments. In addition, rework is
> done on memblock_mem_limit_remove_map() to re-implement it using
> memblock_cap_memory_range().
> 
> This function, like memblock_mem_limit_remove_map(), will not remove
> memblocks with MEMMAP_NOMAP attribute as they may be mapped and accessed
> later as "device memory."
> See the commit a571d4eb55d8 ("mm/memblock.c: add new infrastructure to
> address the mem limit issue").
> 
> This function is used, in a succeeding patch in the series of arm64 kdump
> suuport, to limit the range of usable memory, or System RAM, on crash dump
> kernel.
> (Please note that "mem=" parameter is of little use for this purpose.)
> 
> Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
> Reviewed-by: Will Deacon <will.deacon@arm.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Dennis Chen <dennis.chen@arm.com>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 44 +++++++++++++++++++++++++++++---------------
>  2 files changed, 30 insertions(+), 15 deletions(-)

Andrew, are you ok with patches 1 and 2 in this series (touching
mm/memblock.c and include/linux/memblock.h) to go in via the arm64 tree?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

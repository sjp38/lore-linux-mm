Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB4416B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:26:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x23so93935446pgx.6
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:26:24 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si10115585plh.251.2016.11.24.02.26.23
        for <linux-mm@kvack.org>;
        Thu, 24 Nov 2016 02:26:23 -0800 (PST)
Date: Thu, 24 Nov 2016 10:26:21 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v28 1/9] memblock: add memblock_cap_memory_range()
Message-ID: <20161124102619.GC78338@MBP.local>
References: <20161124095523.6972-1-takahiro.akashi@linaro.org>
 <20161124095717.7037-1-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161124095717.7037-1-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>, will.deacon@arm.com, mark.rutland@arm.com, geoff@infradead.org, kexec@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, linux-arm-kernel@lists.infradead.org

Hi Andrew,

On Thu, Nov 24, 2016 at 06:57:17PM +0900, AKASHI Takahiro wrote:
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
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 44 +++++++++++++++++++++++++++++---------------
>  2 files changed, 30 insertions(+), 15 deletions(-)

Are you OK with this patch to go in via the arm64 tree (together with
the other patches in this series)?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

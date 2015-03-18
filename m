Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 32F846B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:15:44 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so88532093wib.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 05:15:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si3253509wib.111.2015.03.18.05.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 05:15:42 -0700 (PDT)
Message-ID: <55096C6B.4010603@suse.cz>
Date: Wed, 18 Mar 2015 13:15:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv3] mm: Don't offset memmap for flatmem
References: <1426291715-16242-1-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1426291715-16242-1-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Kevin Hilman <khilman@linaro.org>, Arnd Bergman <arnd@arndb.de>, Stephen Boyd <sboyd@codeaurora.org>, linux-mm@kvack.org, Kumar Gala <galak@codeaurora.org>, Mel Gorman <mgorman@suse.de>

On 03/14/2015 01:08 AM, Laura Abbott wrote:
> Srinivas Kandagatla reported bad page messages when trying to
> remove the bottom 2MB on an ARM based IFC6410 board
>
> BUG: Bad page state in process swapper  pfn:fffa8
> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> bad because of flags:
> flags: 0x200041(locked|active|mlocked)
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
> Hardware name: Qualcomm (Flattened Device Tree)
> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
> Disabling lock debugging due to kernel taint
>
> Removing the lower 2MB made the start of the lowmem zone to no longer
> be page block aligned. IFC6410 uses CONFIG_FLATMEM where
> alloc_node_mem_map allocates memory for the mem_map. alloc_node_mem_map
> will offset for unaligned nodes with the assumption the pfn/page
> translation functions will account for the offset. The functions for
> CONFIG_FLATMEM do not offset however, resulting in overrunning
> the memmap array. Just use the allocated memmap without any offset
> when running with CONFIG_FLATMEM to avoid the overrun.
>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> Reported-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

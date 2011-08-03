Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE896B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 08:29:04 -0400 (EDT)
Received: by vxg38 with SMTP id 38so813643vxg.14
        for <linux-mm@kvack.org>; Wed, 03 Aug 2011 05:29:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110803110555.GD19099@suse.de>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
	<20110803110555.GD19099@suse.de>
Date: Wed, 3 Aug 2011 17:59:03 +0530
Message-ID: <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com>
Subject: Re: [PATCH] ARM: sparsemem: Enable CONFIG_HOLES_IN_ZONE config option
 for SparseMem and HAS_HOLES_MEMORYMODEL for linux-3.0.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi Mel,

Sorry for the formatting.

I forgot to include the following entire backtrace:
#> cp test_huge_file nfsmnt
kernel BUG at mm/page_alloc.c:849!
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = ce9f0000
<SNIP>
Backtrace:
[<c00269ac>] (__bug+0x0/0x30) from [<c008e8b0>]
(move_freepages_block+0xd4/0x158)
[<c008e7dc>] (move_freepages_block+0x0/0x158) from [<c008eb10>]
(__rmqueue+0x1dc/0x32c)
 r8:c0481120 r7:c048107c r6:00000003 r5:00000001 r4:c04f8200
r3:00000000
[<c008e934>] (__rmqueue+0x0/0x32c) from [<c00906f8>]
(get_page_from_freelist+0x12c/0x530)
[<c00905cc>] (get_page_from_freelist+0x0/0x530) from [<c0090bec>]
(__alloc_pages_nodemask+0xf0/0x544)
[<c0090afc>] (__alloc_pages_nodemask+0x0/0x544) from [<c00b4da4>]
(cache_alloc_refill+0x2d0/0x654)
[<c00b4ad4>] (cache_alloc_refill+0x0/0x654) from [<c00b5258>]
(kmem_cache_alloc+0x58/0x9c)
[<c00b5200>] (kmem_cache_alloc+0x0/0x9c) from [<c01f0154>]
(radix_tree_preload+0x58/0xbc)
 r7:00006741 r6:000000d0 r5:c04a98a0 r4:ce986000
[<c01f00fc>] (radix_tree_preload+0x0/0xbc) from [<c008ac94>]
(add_to_page_cache_locked+0x20/0x1c4)
 r6:ce987d20 r5:ce346c1c r4:c04f8600 r3:000000d0
[<c008ac74>] (add_to_page_cache_locked+0x0/0x1c4) from [<c008ae84>]
(add_to_page_cache_lru+0x4c/0x7c)
 r8:00000020 r7:ce7402a0 r6:ce987d20 r5:00000005 r4:c04f8600
r3:000000d0
[<c008ae38>] (add_to_page_cache_lru+0x0/0x7c) from [<c00e8428>]
(mpage_readpages+0x7c/0x108)
 r5:00000005 r4:c04f8600
[<c00e83ac>] (mpage_readpages+0x0/0x108) from [<c010f450>]
(fat_readpages+0x20/0x28)
[<c010f430>] (fat_readpages+0x0/0x28) from [<c0092ebc>]
(__do_page_cache_readahead+0x1c4/0x27c)
[<c0092cf8>] (__do_page_cache_readahead+0x0/0x27c) from [<c0092fa0>]
(ra_submit+0x2c/0x34)
[<c0092f74>] (ra_submit+0x0/0x34) from [<c0093294>]
(ondemand_readahead+0x20c/0x21c)
[<c0093088>] (ondemand_readahead+0x0/0x21c) from [<c0093348>]
(page_cache_async_readahead+0xa4/0xd8)
[<c00932a4>] (page_cache_async_readahead+0x0/0xd8) from [<c008c6f4>]
(generic_file_aio_read+0x360/0x7f4)
 r8:00000000 r7:ce346c1c r6:ce88dba0 r5:0000671c r4:c04f9640
[<c008c394>] (generic_file_aio_read+0x0/0x7f4) from [<c00b7954>]
(do_sync_read+0xa0/0xd8)
[<c00b78b4>] (do_sync_read+0x0/0xd8) from [<c00b84d8>] (vfs_read+0xb8/0x154)
 r6:bed53650 r5:ce88dba0 r4:00001000
[<c00b8420>] (vfs_read+0x0/0x154) from [<c00b863c>] (sys_read+0x44/0x70)
 r8:0671c000 r7:00000003 r6:00001000 r5:bed53650 r4:ce88dba0
[<c00b85f8>] (sys_read+0x0/0x70) from [<c0022f80>] (ret_fast_syscall+0x0/0x30)
 r9:ce986000 r8:c0023128 r6:bed53650 r5:00001000 r4:0013a4e0
Code: e59f0010 e1a01003 eb0d0852 e3a03000 (e5833000)
<SNIP>

Since I was testing on linux-2.6.35.9, line 849 in page_alloc.c is the
same line as you have mentioned:
BUG_ON(page_zone(start_page) != page_zone(end_page))

I reproduce this crash by altering the memory banks' memory ranges
such that they are not aligned to the SECTION_SIZE_BITS size.
For example, on my ARM system SECTION_SIZE_BITS is 23(8MB), so I
change the code in arch/arm/mach-* code so that the total kernel
memory
size in the memory banks is lesser by 1 MB, which makes the total
kernel memory size become not exactly divisible by 8 MB.

Thanks,
Kautuk.


On Wed, Aug 3, 2011 at 4:35 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Aug 02, 2011 at 05:38:31PM +0530, Kautuk Consul wrote:
>> Hi,
>>
>> In the case where the total kernel memory is not aligned to the
>> SECTION_SIZE_BITS I see a kernel crash.
>>
>> When I copy a huge file, then the kernel crashes at the following callstack:
>>
>
> The callstack should not be 80-column formatted as this is completely
> manged and unreadable without manual editting. Also, why did you not
> include the full error message? With it, I'd have a better idea of
> which bug check you hit.
>
>> Backtrace:
>> <SNIP>
>>
>> The reason for this is that the CONFIG_HOLES_IN_ZONE configuration
>> option is not automatically enabled when SPARSEMEM or
>> ARCH_HAS_HOLES_MEMORYMODEL are enabled. Due to this, the
>> pfn_valid_within() macro always returns 1 due to which the BUG_ON is
>> encountered.
>> This patch enables the CONFIG_HOLES_IN_ZONE config option if either
>> ARCH_HAS_HOLES_MEMORYMODEL or SPARSEMEM is enabled.
>>
>> Although I tested this on an older kernel, i.e., 2.6.35.13, I see that
>> this option has not been enabled as yet in linux-3.0 and this appears
>> to be a
>> logically correct change anyways with respect to pfn_valid_within()
>> functionality.
>>
>
> There is a performance cost associated with HOLES_IN_ZONE which may be
> offset by memory savings but not necessarily.
>
> If the BUG_ON you are hitting is this one
> BUG_ON(page_zone(start_page) != page_zone(end_page)) then I'd be
> wondering why the check in move_freepages_block() was insufficient.
>
> If it's because holes are punched in the memmap then the option does
> need to be set.
>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

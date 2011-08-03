Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A02526B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 09:28:44 -0400 (EDT)
Date: Wed, 3 Aug 2011 14:28:39 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] ARM: sparsemem: Enable CONFIG_HOLES_IN_ZONE config
 option for SparseMem and HAS_HOLES_MEMORYMODEL for linux-3.0.
Message-ID: <20110803132839.GG19099@suse.de>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
 <20110803110555.GD19099@suse.de>
 <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Wed, Aug 03, 2011 at 05:59:03PM +0530, Kautuk Consul wrote:
> Hi Mel,
> 
> Sorry for the formatting.
> 
> I forgot to include the following entire backtrace:
> #> cp test_huge_file nfsmnt
> kernel BUG at mm/page_alloc.c:849!
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> pgd = ce9f0000
> <SNIP>
> Backtrace:
> [<c00269ac>] (__bug+0x0/0x30) from [<c008e8b0>]
> (move_freepages_block+0xd4/0x158)

It's still horribly mangled and pretty much unreadable but at least we
know where the bug is hitting.

> <SNIP>
> 
> Since I was testing on linux-2.6.35.9, line 849 in page_alloc.c is the
> same line as you have mentioned:
> BUG_ON(page_zone(start_page) != page_zone(end_page))
> 
> I reproduce this crash by altering the memory banks' memory ranges
> such that they are not aligned to the SECTION_SIZE_BITS size.

How are you altering the ranges? Are you somehow breaking
the checks based on the information in stuct zone that is in
move_freepages_block()?

It no longer seems like a punching-hole-in-memmap problem. Can
you investigate how and why the range of pages passed in to
move_freepages() belong to different zones?

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

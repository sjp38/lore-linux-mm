Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 866066B6777
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 06:50:26 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s200-v6so133422oie.6
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 03:50:26 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e77-v6si12390072oib.82.2018.09.03.03.50.25
        for <linux-mm@kvack.org>;
        Mon, 03 Sep 2018 03:50:25 -0700 (PDT)
Date: Mon, 3 Sep 2018 11:50:38 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arm64: Kconfig: Remove ARCH_HAS_HOLES_MEMORYMODEL
Message-ID: <20180903105037.GC11055@arm.com>
References: <20180831151943.9281-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831151943.9281-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

On Fri, Aug 31, 2018 at 04:19:43PM +0100, James Morse wrote:
> include/linux/mmzone.h describes ARCH_HAS_HOLES_MEMORYMODEL as
> relevant when parts the memmap have been free()d. This would
> happen on systems where memory is smaller than a sparsemem-section,
> and the extra struct pages are expensive. pfn_valid() on these
> systems returns true for the whole sparsemem-section, so an extra
> memmap_valid_within() check is needed.
> 
> On arm64 we have nomap memory, so always provide pfn_valid() to test
> for nomap pages. This means ARCH_HAS_HOLES_MEMORYMODEL's extra checks
> are already rolled up into pfn_valid().
> 
> Remove it.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  arch/arm64/Kconfig            | 5 +----
>  arch/arm64/include/asm/page.h | 2 --
>  arch/arm64/mm/init.c          | 2 --
>  3 files changed, 1 insertion(+), 8 deletions(-)

Acked-by: Will Deacon <will.deacon@arm.com>

Will

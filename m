Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9C96B039C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:52:59 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id h1so1667428oti.6
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 10:52:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e84-v6si3657880oig.43.2018.10.29.10.52.58
        for <linux-mm@kvack.org>;
        Mon, 29 Oct 2018 10:52:58 -0700 (PDT)
Date: Mon, 29 Oct 2018 17:53:04 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 1/6] mm: Introduce common STRUCT_PAGE_MAX_SHIFT define
Message-ID: <20181029175303.GB16739@arm.com>
References: <20181015175702.9036-1-logang@deltatee.com>
 <20181015175702.9036-2-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015175702.9036-2-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>

Hi Logan,

On Mon, Oct 15, 2018 at 11:56:57AM -0600, Logan Gunthorpe wrote:
> This define is used by arm64 to calculate the size of the vmemmap
> region. It is defined as the log2 of the upper bound on the size
> of a struct page.
> 
> We move it into mm_types.h so it can be defined properly instead of
> set and checked with a build bug. This also allows us to use the same
> define for riscv.
> 
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm64/include/asm/memory.h | 9 ---------
>  arch/arm64/mm/init.c            | 8 --------
>  include/asm-generic/fixmap.h    | 1 +
>  include/linux/mm_types.h        | 5 +++++
>  4 files changed, 6 insertions(+), 17 deletions(-)

This looks like a really good cleanup to me, thanks:

Acked-by: Will Deacon <will.deacon@arm.com>

Will

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 545C18E0003
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 18:58:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so6334420edb.5
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 15:58:09 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s17si511258edr.396.2019.01.19.15.58.07
        for <linux-mm@kvack.org>;
        Sat, 19 Jan 2019 15:58:07 -0800 (PST)
Date: Sat, 19 Jan 2019 23:57:57 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] hugetlb: allow to free gigantic pages regardless of the
 configuration
Message-ID: <20190119235756.GF26876@brain-police>
References: <20190117183953.5990-1-aghiti@upmem.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190117183953.5990-1-aghiti@upmem.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <aghiti@upmem.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, linux-riscv@lists.infradead.org, Alexandre Ghiti <alex@ghiti.fr>

On Thu, Jan 17, 2019 at 06:39:53PM +0000, Alexandre Ghiti wrote:
> From: Alexandre Ghiti <alex@ghiti.fr>
> 
> On systems without CMA or (MEMORY_ISOLATION && COMPACTION) activated but
> that support gigantic pages, boottime reserved gigantic pages can not be
> freed at all. This patchs simply enables the possibility to hand back
> those pages to memory allocator.
> 
> This commit then renames gigantic_page_supported and
> ARCH_HAS_GIGANTIC_PAGE to make them more accurate. Indeed, those values
> being false does not mean that the system cannot use gigantic pages: it
> just means that runtime allocation of gigantic pages is not supported,
> one can still allocate boottime gigantic pages if the architecture supports
> it.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
> 
> - Compiled on all architectures
> - Tested on riscv architecture
> 
>  arch/arm64/Kconfig                           |  2 +-
>  arch/arm64/include/asm/hugetlb.h             |  7 +++--

The arm64 bits look straightforward enough to me...

Acked-by: Will Deacon <will.deacon@arm.com>

Will

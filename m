Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 5F3606B0185
	for <linux-mm@kvack.org>; Wed,  1 May 2013 10:16:22 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id c10so4949044wiw.6
        for <linux-mm@kvack.org>; Wed, 01 May 2013 07:16:20 -0700 (PDT)
Date: Wed, 1 May 2013 15:16:14 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH 9/9] ARM64: mm: THP support.
Message-ID: <20130501141613.GA23462@linaro.org>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-10-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339448-21727-10-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tue, Apr 30, 2013 at 05:30:48PM +0100, Steve Capper wrote:
> Bring Transparent HugePage support to ARM. The size of a
> transparent huge page depends on the normal page size. A
> transparent huge page is always represented as a pmd.
> 
> If PAGE_SIZE is 4K, THPs are 2MB.
> If PAGE_SIZE is 64K, THPs are 512MB.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  arch/arm64/Kconfig                     |  3 +++
>  arch/arm64/include/asm/pgtable-hwdef.h |  1 +
>  arch/arm64/include/asm/pgtable.h       | 47 ++++++++++++++++++++++++++++++++++
>  arch/arm64/include/asm/tlb.h           |  6 +++++
>  arch/arm64/include/asm/tlbflush.h      |  2 ++
>  5 files changed, 59 insertions(+)
> 

[ ... ]

> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 4b7a058..06bfbd6 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h

[ ... ]

> +#define pmd_modify(pmd,newprot)	(__pmd(pmd_val(pmd) | pgprot_val(newprot)))
> +#define set_pmd_at(mm, addr, pmdp, pmd)	set_pmd(pmdp, pmd)

Apologies, I have over-simplified (and broke) pmd_modify whilst tidying up this
patch. It should mask off certain bits. I will send out a correction once
PROT_NONE support has been sorted as this will affect this code path too.

--
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

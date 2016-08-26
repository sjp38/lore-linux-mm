Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 244B983090
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 06:26:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so139006881pfd.3
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 03:26:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u190si20640219pfb.43.2016.08.26.03.26.18
        for <linux-mm@kvack.org>;
        Fri, 26 Aug 2016 03:26:18 -0700 (PDT)
Date: Fri, 26 Aug 2016 11:26:18 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH v3 0/2] arm64/hugetlb: enable gigantic page
Message-ID: <20160826102617.GG13554@arm.com>
References: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Mon, Aug 22, 2016 at 09:20:02PM +0800, Xie Yisheng wrote:
> Arm64 supports different size of gigantic page which can be seen from:
> commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
> commit 66b3923a1a0f ("arm64: hugetlb: add support for PTE contiguous bit")
> 
> So I tried to use this function by adding hugepagesz=1G in kernel
> parameters, with CONFIG_CMA=y. However, when I
> echo xx > \
>   /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages
> it failed with the following info:
> -bash: echo: write error: Invalid argument
> 
> This is a v3 patchset which make gigantic page can be
> allocated and freed at runtime for arch arm64,
> with CONFIG_CMA=y or other related configs is enabled.
> 
> You can see the former discussions at:
> https://lkml.org/lkml/2016/8/18/310
> https://lkml.org/lkml/2016/8/21/410
>  
> Xie Yisheng (2):
>   mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
>   arm64 Kconfig: Select gigantic page
> 
>  arch/arm64/Kconfig | 1 +
>  arch/s390/Kconfig  | 1 +
>  arch/x86/Kconfig   | 1 +
>  fs/Kconfig         | 3 ++++
>  mm/hugetlb.c       | 2 +-
>  5 files changed, 7 insertions(+), 1 deletion(-)

I assume you plan to merge this via -mm/akpm, given that Catalin has
acked the arm64 part?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

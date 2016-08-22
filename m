Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01E086B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:21:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so189713639pfx.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:21:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id zr3si25268295pac.131.2016.08.22.03.21.33
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 03:21:33 -0700 (PDT)
Date: Mon, 22 Aug 2016 11:21:27 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH v2 2/2] arm64 Kconfig: Select gigantic page
Message-ID: <20160822102127.GB26494@e104818-lin.cambridge.arm.com>
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
 <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, mark.rutland@arm.com, mhocko@suse.com, linux-mm@kvack.org, sudeep.holla@arm.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, robh+dt@kernel.org, guohanjun@huawei.com, n-horiguchi@ah.jp.nec.com, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com

On Mon, Aug 22, 2016 at 10:56:43AM +0800, Xie Yisheng wrote:
> Arm64 supports gigantic page after
> commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
> however, it got broken by 
> commit 944d9fec8d7a ("hugetlb: add support for gigantic page
> allocation at runtime")
> 
> This patch selects ARCH_HAS_GIGANTIC_PAGE to make this
> function can be used again.
> 
> Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>
> ---
>  arch/arm64/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index bc3f00f..92217f6 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -9,6 +9,7 @@ config ARM64
>  	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> +	select ARCH_HAS_GIGANTIC_PAGE

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

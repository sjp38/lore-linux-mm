Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 953C66B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:04:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so55670550wml.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:04:01 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id b6si17362803wji.156.2016.08.22.01.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 01:04:00 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so12236888wme.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:04:00 -0700 (PDT)
Date: Mon, 22 Aug 2016 10:03:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 2/2] arm64 Kconfig: Select gigantic page
Message-ID: <20160822080358.GF13596@dhcp22.suse.cz>
References: <1471834603-27053-1-git-send-email-xieyisheng1@huawei.com>
 <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471834603-27053-3-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, will.deacon@arm.com, dave.hansen@intel.com, sudeep.holla@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com, robh+dt@kernel.org, linux-arm-kernel@lists.infradead.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Mon 22-08-16 10:56:43, Xie Yisheng wrote:
> Arm64 supports gigantic page after
> commit 084bd29810a5 ("ARM64: mm: HugeTLB support.")
> however, it got broken by 
> commit 944d9fec8d7a ("hugetlb: add support for gigantic page
> allocation at runtime")
> 
> This patch selects ARCH_HAS_GIGANTIC_PAGE to make this
> function can be used again.

I haven't double checked that the above commit really broke it but if
that is the case then
 
Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")

would be nice as well I guess. I do not think that marking it for stable
is really necessary considering how long it's been broken and nobody has
noticed...

> Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

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
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_SG_CHAIN
>  	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

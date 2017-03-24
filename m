Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5B076B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:10:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 20so3131247wrx.6
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:10:41 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 88si3473956wre.255.2017.03.24.07.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 07:10:40 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id z133so832635wmb.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:10:39 -0700 (PDT)
Date: Fri, 24 Mar 2017 17:10:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 04/11] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Message-ID: <20170324141037.2eyovzq2bmcdmwzu@node.shutemov.name>
References: <20170313154507.3647-1-zi.yan@sent.com>
 <20170313154507.3647-5-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313154507.3647-5-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On Mon, Mar 13, 2017 at 11:45:00AM -0400, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
> functionality to x86_64, which should be safer at the first step.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> v1 -> v2:
> - fixed config name in subject and patch description
> ---
>  arch/x86/Kconfig        |  4 ++++
>  include/linux/huge_mm.h | 10 ++++++++++
>  mm/Kconfig              |  3 +++
>  3 files changed, 17 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 69188841717a..a24bc11c7aed 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -2276,6 +2276,10 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	def_bool y
>  	depends on X86_64 && HUGETLB_PAGE && MIGRATION
>  
> +config ARCH_ENABLE_THP_MIGRATION
> +	def_bool y
> +	depends on X86_64 && TRANSPARENT_HUGEPAGE && MIGRATION
> +

TRANSPARENT_HUGEPAGE implies MIGRATION due to COMPACTION.


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

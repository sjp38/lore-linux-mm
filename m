Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B18F6B025E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 20:01:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fi2so168581458pad.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:01:56 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p11si16665302par.193.2016.09.29.17.01.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 17:01:55 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 6so4161364pfl.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 17:01:55 -0700 (PDT)
Subject: Re: [PATCH v1 12/12] mm: ppc64: Add THP migration support for ppc64.
References: <20160926152234.14809-1-zi.yan@sent.com>
 <20160926152234.14809-13-zi.yan@sent.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ea79747c-5eb4-7413-3163-45c449bb94ad@gmail.com>
Date: Fri, 30 Sep 2016 10:02:33 +1000
MIME-Version: 1.0
In-Reply-To: <20160926152234.14809-13-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zi.yan@sent.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: benh@kernel.crashing.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>



On 27/09/16 01:22, zi.yan@sent.com wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  arch/powerpc/Kconfig                         |  4 ++++
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 23 +++++++++++++++++++++++
>  2 files changed, 27 insertions(+)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 927d2ab..84ffd4c 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -553,6 +553,10 @@ config ARCH_SPARSEMEM_DEFAULT
>  config SYS_SUPPORTS_HUGETLBFS
>  	bool
>  
> +config ARCH_ENABLE_THP_MIGRATION
> +	def_bool y
> +	depends on PPC64 && TRANSPARENT_HUGEPAGE && MIGRATION

I had done the same patch before but never posted it, since Nayomi's patches
were blocked behind _PAGE_PSE (x86 specific concern for __pmdp_present())

Having said that this addition looks good to me

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

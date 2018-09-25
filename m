Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5B4B8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:05:20 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id c46-v6so28301891otd.12
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:05:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p129-v6si1334674oif.151.2018.09.25.14.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 14:05:20 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8PKxK4f031537
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:05:19 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mqt8b60bs-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:05:19 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Sep 2018 22:05:17 +0100
Date: Wed, 26 Sep 2018 00:05:09 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 1/4] mm: Remove now defunct NO_BOOTMEM from depends
 list for deferred init
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201814.3576.15105.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925201814.3576.15105.stgit@localhost.localdomain>
Message-Id: <20180925210509.GA13839@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Tue, Sep 25, 2018 at 01:19:15PM -0700, Alexander Duyck wrote:
> The CONFIG_NO_BOOTMEM config option was recently removed by the patch "mm:
> remove CONFIG_NO_BOOTMEM" (https://patchwork.kernel.org/patch/10600647/).
> However it looks like it missed a few spots. The biggest one being the
> dependency for deferred init. This patch goes through and removes the
> remaining spots that appear to have been missed in the patch so that I am
> able to build again with deferred memory initialization.

Thanks for fixing it!
 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
> 
> v5: New patch, added to fix regression found in latest linux-next
> 
>  arch/csky/Kconfig |    1 -
>  mm/Kconfig        |    1 -
>  2 files changed, 2 deletions(-)
> 
> diff --git a/arch/csky/Kconfig b/arch/csky/Kconfig
> index fe2c94b94fe3..fb2a0ae84dd5 100644
> --- a/arch/csky/Kconfig
> +++ b/arch/csky/Kconfig
> @@ -38,7 +38,6 @@ config CSKY
>  	select HAVE_MEMBLOCK
>  	select MAY_HAVE_SPARSE_IRQ
>  	select MODULES_USE_ELF_RELA if MODULES
> -	select NO_BOOTMEM



>  	select OF
>  	select OF_EARLY_FLATTREE
>  	select OF_RESERVED_MEM
> diff --git a/mm/Kconfig b/mm/Kconfig
> index c6a0d82af45f..b4421aa608c4 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -631,7 +631,6 @@ config MAX_STACK_SIZE_MB
>  config DEFERRED_STRUCT_PAGE_INIT
>  	bool "Defer initialisation of struct pages to kthreads"
>  	default n
> -	depends on NO_BOOTMEM
>  	depends on SPARSEMEM
>  	depends on !NEED_PER_CPU_KM
>  	depends on 64BIT
> 

-- 
Sincerely yours,
Mike.

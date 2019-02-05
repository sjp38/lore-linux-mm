Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5CB6C282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 704FE207E0
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 11:23:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 704FE207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200D58E0080; Tue,  5 Feb 2019 06:23:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B03F8E001C; Tue,  5 Feb 2019 06:23:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C6498E0080; Tue,  5 Feb 2019 06:23:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0D7B8E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 06:23:58 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so2055712pgb.7
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 03:23:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=RSfoYNyZ118JrgWAhpOKUAEkPrDahBdi1FwN30jTV/w=;
        b=RH75N7t741/H3q0+BvAie/cmCEhGo29JmoziQdqvYULFGrbpMcLXIG2ur2TQIvwolJ
         WcfjXnvOwwa+TEY+mSbQyC4fHFqYOn4fDwHmfAWGz50F/wAfkxBm69UFFOR49PQ6iy4H
         wdSfRYOrS3HoAmNAsZ+wwj4zB9QR32znFOJsV6jOxqTP+s016rbLVG/CSBGJ6Z7KAjfV
         mTb8VgID3L6Mb3vD62aIjsv7myVWEZKm/IGXo95ANcqmc8PXLbGzzLTq9+AIpeXJldmr
         v/dpmDAZn2ol5888dB2lkkX2MLEdEmz3aYWF1b5d+Utb9+2P6BM7GoGBQtgWOVBvfkHI
         oOQw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuaFxO4QOLenT8yrrb3hqFlvmcCtyD6kWDM7DjmFucuDYXEyZ1NH
	fwVhGWUPvwiD7go6A0ykqPSb8kALP/Zbi6a0Qy4Y2e8K4Hg5LiZAdkueanfTnyPwWKZoks6uKSD
	7mnyv00tFBIrulNgdrF2eNNOrtKcNXfp4UJhKOQ/AbDuyHCoaFDbZLumCAkGXnik=
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr4452607pls.245.1549365838302;
        Tue, 05 Feb 2019 03:23:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBtWXvrkbMeebPX7/hp8zdU37Rqjlj+YPlO0RZ5evomeJzf7LJpb3guZ5CjQPZf5L6tryr
X-Received: by 2002:a17:902:b602:: with SMTP id b2mr4452503pls.245.1549365837175;
        Tue, 05 Feb 2019 03:23:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549365837; cv=none;
        d=google.com; s=arc-20160816;
        b=XGAhi4LAOfdfB1i2YSzPWz7t8YQ4C78e9Fs+h9MKBykFTE0bbzgeTnXleDXQ2PtjH6
         7SGG/NlK/Anh0YEBwBdaOcv7xyKIepqdPHgYtHRMyE57QssAHoigwZsN7WfNNCIN0j2a
         EQDt0oPSM38/aJQKuyqexPc5uWfN3mE5vS2li5vaUWdQLrmuk+RMuGZ4Fty1DLQ3ttDP
         20ScmcBKsrhja8w1EIoXu2oOYFXZI66H2A3cPhlzl1p/OdI6K+es/bnPmM9BA6SE56rh
         cggVnFihGZ7wQJ+P3FEbgY/7h49aQgjUn0tG2hRucJspTr92amzmzRF/m9qzO84R6ree
         pbww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=RSfoYNyZ118JrgWAhpOKUAEkPrDahBdi1FwN30jTV/w=;
        b=eQM18tQkRDYVzQxXlRvNY8DgIkoh1cq/FkQ70v68fkOzRQwFpCRN1Hw+Hs+yaKb9vd
         k0aFrns3XTDUW2jWiAZyDsA4KsyM5O0g6w4ZbX9mykXc2ASwvden20oOnvXLKi9URHqJ
         R6iVf2bN8uL+r+zlYhXxeFALmAMRxk2yx2WhUVjnsiWFIztNCC7W0NJks/Eb/cV+shBr
         4rxj6ROMRa8UZFRNSwhoIYiqYC+o0ShQ+v/p3MMArx7m/2suuqRtHQf45L/gWCEpT1CW
         0yt3FOeUTQ4Gnr1XYZpn1rMecvoVjr3JMomoT0k5Q3AkPoMkfaZhIzHeQ4MSmA/ewKIn
         N6JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id b11si3113825plb.427.2019.02.05.03.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 03:23:57 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43v2Jn1pDRz9sMp;
	Tue,  5 Feb 2019 22:23:52 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Alexandre Ghiti <aghiti@upmem.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-riscv@lists.infradead.org, hch@infradead.org, Alexandre Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH] hugetlb: allow to free gigantic pages regardless of the configuration
In-Reply-To: <20190117183953.5990-1-aghiti@upmem.com>
References: <20190117183953.5990-1-aghiti@upmem.com>
Date: Tue, 05 Feb 2019 22:23:51 +1100
Message-ID: <87ef8mmqbc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre Ghiti <aghiti@upmem.com> writes:

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
>  arch/powerpc/include/asm/book3s/64/hugetlb.h |  4 +--
>  arch/powerpc/platforms/Kconfig.cputype       |  2 +-

The powerpc parts look fine.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

>  arch/s390/Kconfig                            |  2 +-
>  arch/s390/include/asm/hugetlb.h              |  7 +++--
>  arch/x86/Kconfig                             |  2 +-
>  arch/x86/include/asm/hugetlb.h               |  7 +++--
>  fs/Kconfig                                   |  2 +-
>  include/linux/gfp.h                          |  2 +-
>  mm/hugetlb.c                                 | 43 +++++++++++++++-------------
>  mm/page_alloc.c                              |  4 +--
>  12 files changed, 48 insertions(+), 36 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a4168d366127..18239cbd7fcd 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -18,7 +18,7 @@ config ARM64
>  	select ARCH_HAS_FAST_MULTIPLIER
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION if (MEMORY_ISOLATION && COMPACTION) || CMA
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_MEMBARRIER_SYNC_CORE
>  	select ARCH_HAS_PTE_SPECIAL
> diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
> index fb6609875455..797fc77eabcd 100644
> --- a/arch/arm64/include/asm/hugetlb.h
> +++ b/arch/arm64/include/asm/hugetlb.h
> @@ -65,8 +65,11 @@ extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
>  
>  #include <asm-generic/hugetlb.h>
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void) { return true; }
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
> +static inline bool gigantic_page_runtime_allocation_supported(void)
> +{
> +	return true;
> +}
>  #endif
>  
>  #endif /* __ASM_HUGETLB_H */
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 5b0177733994..7711f0e2c7e5 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -32,8 +32,8 @@ static inline int hstate_get_psize(struct hstate *hstate)
>  	}
>  }
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void)
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
> +static inline bool gigantic_page_runtime_allocation_supported(void)
>  {
>  	return true;
>  }
> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
> index 8c7464c3f27f..779e06bac697 100644
> --- a/arch/powerpc/platforms/Kconfig.cputype
> +++ b/arch/powerpc/platforms/Kconfig.cputype
> @@ -319,7 +319,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  config PPC_RADIX_MMU
>  	bool "Radix MMU Support"
>  	depends on PPC_BOOK3S_64
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION if (MEMORY_ISOLATION && COMPACTION) || CMA
>  	default y
>  	help
>  	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index ed554b09eb3f..6776eef6a9ae 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -69,7 +69,7 @@ config S390
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION if (MEMORY_ISOLATION && COMPACTION) || CMA
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_PTE_SPECIAL
>  	select ARCH_HAS_SET_MEMORY
> diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
> index 2d1afa58a4b6..57c952f5388e 100644
> --- a/arch/s390/include/asm/hugetlb.h
> +++ b/arch/s390/include/asm/hugetlb.h
> @@ -116,7 +116,10 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
>  	return pte_modify(pte, newprot);
>  }
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void) { return true; }
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
> +static inline bool gigantic_page_runtime_allocation_supported(void)
> +{
> +	return true;
> +}
>  #endif
>  #endif /* _ASM_S390_HUGETLB_H */
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 6185d4f33296..a88f5a4311c9 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -23,7 +23,7 @@ config X86_64
>  	def_bool y
>  	depends on 64BIT
>  	# Options that are inherently 64-bit kernel only:
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION if (MEMORY_ISOLATION && COMPACTION) || CMA
>  	select ARCH_SUPPORTS_INT128
>  	select ARCH_USE_CMPXCHG_LOCKREF
>  	select HAVE_ARCH_SOFT_DIRTY
> diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> index 7469d321f072..5a5e7119ced4 100644
> --- a/arch/x86/include/asm/hugetlb.h
> +++ b/arch/x86/include/asm/hugetlb.h
> @@ -17,8 +17,11 @@ static inline void arch_clear_hugepage_flags(struct page *page)
>  {
>  }
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
> -static inline bool gigantic_page_supported(void) { return true; }
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
> +static inline bool gigantic_page_runtime_allocation_supported(void)
> +{
> +	return true;
> +}
>  #endif
>  
>  #endif /* _ASM_X86_HUGETLB_H */
> diff --git a/fs/Kconfig b/fs/Kconfig
> index ac474a61be37..4192d1fde0f0 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -207,7 +207,7 @@ config HUGETLB_PAGE
>  config MEMFD_CREATE
>  	def_bool TMPFS || HUGETLBFS
>  
> -config ARCH_HAS_GIGANTIC_PAGE
> +config ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
>  	bool
>  
>  source "fs/configfs/Kconfig"
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5f5e25fd6149..79ff86fabd42 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
>  /* The below functions must be run on a range from a single zone. */
>  extern int alloc_contig_range(unsigned long start, unsigned long end,
>  			      unsigned migratetype, gfp_t gfp_mask);
> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  #endif
> +extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);
>  
>  #ifdef CONFIG_CMA
>  /* CMA stuff */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 745088810965..9893ba26b3b8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1035,7 +1035,6 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>  		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>  		nr_nodes--)
>  
> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>  static void destroy_compound_gigantic_page(struct page *page,
>  					unsigned int order)
>  {
> @@ -1058,6 +1057,7 @@ static void free_gigantic_page(struct page *page, unsigned int order)
>  	free_contig_range(page_to_pfn(page), 1 << order);
>  }
>  
> +#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION
>  static int __alloc_gigantic_page(unsigned long start_pfn,
>  				unsigned long nr_pages, gfp_t gfp_mask)
>  {
> @@ -1143,22 +1143,19 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>  static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
>  static void prep_compound_gigantic_page(struct page *page, unsigned int order);
>  
> -#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
> -static inline bool gigantic_page_supported(void) { return false; }
> +#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE_RUNTIME_ALLOCATION */
> +static inline bool gigantic_page_runtime_allocation_supported(void)
> +{
> +	return false;
> +}
>  static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>  		int nid, nodemask_t *nodemask) { return NULL; }
> -static inline void free_gigantic_page(struct page *page, unsigned int order) { }
> -static inline void destroy_compound_gigantic_page(struct page *page,
> -						unsigned int order) { }
>  #endif
>  
>  static void update_and_free_page(struct hstate *h, struct page *page)
>  {
>  	int i;
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return;
> -
>  	h->nr_huge_pages--;
>  	h->nr_huge_pages_node[page_to_nid(page)]--;
>  	for (i = 0; i < pages_per_huge_page(h); i++) {
> @@ -2276,13 +2273,20 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
>  }
>  
>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
> -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
>  						nodemask_t *nodes_allowed)
>  {
>  	unsigned long min_count, ret;
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
> -		return h->max_huge_pages;
> +	if (hstate_is_gigantic(h) &&
> +		!gigantic_page_runtime_allocation_supported()) {
> +		spin_lock(&hugetlb_lock);
> +		if (count > persistent_huge_pages(h)) {
> +			spin_unlock(&hugetlb_lock);
> +			return -EINVAL;
> +		}
> +		goto decrease_pool;
> +	}
>  
>  	/*
>  	 * Increase the pool size
> @@ -2322,6 +2326,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  			goto out;
>  	}
>  
> +decrease_pool:
>  	/*
>  	 * Decrease the pool size
>  	 * First return free pages to the buddy allocator (being careful
> @@ -2350,9 +2355,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>  			break;
>  	}
>  out:
> -	ret = persistent_huge_pages(h);
> +	h->max_huge_pages = persistent_huge_pages(h);
>  	spin_unlock(&hugetlb_lock);
> -	return ret;
> +
> +	return 0;
>  }
>  
>  #define HSTATE_ATTR_RO(_name) \
> @@ -2404,11 +2410,6 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  	int err;
>  	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
> -		err = -EINVAL;
> -		goto out;
> -	}
> -
>  	if (nid == NUMA_NO_NODE) {
>  		/*
>  		 * global hstate attribute
> @@ -2428,7 +2429,9 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  	} else
>  		nodes_allowed = &node_states[N_MEMORY];
>  
> -	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
> +	err = set_max_huge_pages(h, count, nodes_allowed);
> +	if (err)
> +		goto out;
>  
>  	if (nodes_allowed != &node_states[N_MEMORY])
>  		NODEMASK_FREE(nodes_allowed);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cde5dac6229a..81b931db85a1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8241,8 +8241,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  				pfn_max_align_up(end), migratetype);
>  	return ret;
>  }
> +#endif
>  
> -void free_contig_range(unsigned long pfn, unsigned nr_pages)
> +void free_contig_range(unsigned long pfn, unsigned int nr_pages)
>  {
>  	unsigned int count = 0;
>  
> @@ -8254,7 +8255,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>  	}
>  	WARN(count != 0, "%d pages are still in use!\n", count);
>  }
> -#endif
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  /*
> -- 
> 2.16.2


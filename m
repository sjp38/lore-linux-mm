Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97ACF6B02FA
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 00:07:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b9so10972193pfl.0
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 21:07:39 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id b17si3404426pgn.287.2017.06.07.21.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Jun 2017 21:07:38 -0700 (PDT)
In-Reply-To: <20170502051706.19043-2-bsingharora@gmail.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [v3,1/3] powerpc/mm/book(e)(3s)/64: Add page table accounting
Message-Id: <3wjsMX2r61z9s8F@ozlabs.org>
Date: Thu,  8 Jun 2017 14:07:36 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, vdavydov.dev@gmail.com, oss@buserror.net
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, 2017-05-02 at 05:17:04 UTC, Balbir Singh wrote:
> Introduce a helper pgtable_gfp_flags() which
> just returns the current gfp flags and adds
> __GFP_ACCOUNT to account for page table allocation.
> The generic helper is added to include/asm/pgalloc.h
> and has two variants - WARNING ugly bits ahead
> 
> 1. If the header is included from a module, no check
> for mm == &init_mm is done, since init_mm is not
> exported
> 2. For kernel includes, the check is done and required
> see (3e79ec7 arch: x86: charge page tables to kmemcg)
> 
> The fundamental assumption is that no module should be
> doing pgd/pud/pmd and pte alloc's on behalf of init_mm
> directly.
> 
> NOTE: This adds an overhead to pmd/pud/pgd allocations
> similar to x86.  The other alternative was to implement
> pmd_alloc_kernel/pud_alloc_kernel and pgd_alloc_kernel
> with their offset variants.
> 
> For 4k page size, pte_alloc_one no longer calls
> pte_alloc_one_kernel.
> 
> Signed-off-by: Balbir Singh <bsingharora@gmail.com>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/de3b87611dd1f3c00f4e42fe298457

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

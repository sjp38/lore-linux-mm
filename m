Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6060F8E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 12:36:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so8079038edc.6
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 09:36:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 29-v6si4759382ejk.274.2019.01.13.09.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 09:35:59 -0800 (PST)
Date: Sun, 13 Jan 2019 18:35:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
Message-ID: <20190113173555.GC1578@dhcp22.suse.cz>
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com

On Sat 12-01-19 15:56:38, Anshuman Khandual wrote:
> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> __GFP_ZERO) and using it for allocating page table pages. This causes some
> code duplication which can be easily avoided. GFP_KERNEL allocated and
> cleared out pages (__GFP_ZERO) are required for page tables on any given
> architecture. This creates a new generic GFP flag flag which can be used
> for any page table page allocation. Does not cause any functional change.

I agree that some unification is due but GFP_PGTABLE is not something to
expose in generic gfp.h IMHO. It just risks an abuse. I would be looking
at providing asm-generic implementation and reuse it to remove the code
duplication. But I haven't tried that to know that it will work out due
to small/subtle differences between arches.

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
-- 
Michal Hocko
SUSE Labs

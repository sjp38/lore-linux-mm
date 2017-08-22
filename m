Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99C00280310
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:11:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o82so68066056pfj.11
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 03:11:25 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h5si9647733pln.768.2017.08.22.03.11.24
        for <linux-mm@kvack.org>;
        Tue, 22 Aug 2017 03:11:24 -0700 (PDT)
Date: Tue, 22 Aug 2017 11:11:18 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] mm/hugetlb.c: make huge_pte_offset() consistent and
 document behaviour
Message-ID: <20170822101117.ilnys32tugytbbjc@armageddon.cambridge.arm.com>
References: <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170818145415.7588-1-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818145415.7588-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Aug 18, 2017 at 03:54:15PM +0100, Punit Agrawal wrote:
> When walking the page tables to resolve an address that points to
> !p*d_present() entry, huge_pte_offset() returns inconsistent values
> depending on the level of page table (PUD or PMD).
> 
> It returns NULL in the case of a PUD entry while in the case of a PMD
> entry, it returns a pointer to the page table entry.
> 
> A similar inconsitency exists when handling swap entries - returns NULL
> for a PUD entry while a pointer to the pte_t is retured for the PMD entry.
> 
> Update huge_pte_offset() to make the behaviour consistent - return a
> pointer to the pte_t for hugepage or swap entries. Only return NULL in
> instances where we have a p*d_none() entry and the size parameter
> doesn't match the hugepage size at this level of the page table.
> 
> Document the behaviour to clarify the expected behaviour of this function.
> This is to set clear semantics for architecture specific implementations
> of huge_pte_offset().
> 
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>

FWIW:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

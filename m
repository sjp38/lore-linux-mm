Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C44EF6B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 08:54:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so22532145wmu.3
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 05:54:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s7sor3071922edi.48.2017.10.08.05.54.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 05:54:51 -0700 (PDT)
Date: Sun, 8 Oct 2017 15:54:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] mm: Introduce wrappers to access mm->nr_ptes
Message-ID: <20171008125449.kgzjilgxzbropewj@node.shutemov.name>
References: <20171005101442.49555-1-kirill.shutemov@linux.intel.com>
 <7e476fd2-5818-c395-cdf2-00b5229c1a73@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e476fd2-5818-c395-cdf2-00b5229c1a73@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On Fri, Oct 06, 2017 at 04:10:31PM -0700, Dave Hansen wrote:
> On 10/05/2017 03:14 AM, Kirill A. Shutemov wrote:
> > +++ b/arch/sparc/mm/hugetlbpage.c
> > @@ -396,7 +396,7 @@ static void hugetlb_free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
> >  
> >  	pmd_clear(pmd);
> >  	pte_free_tlb(tlb, token, addr);
> > -	atomic_long_dec(&tlb->mm->nr_ptes);
> > +	mm_dec_nr_ptes(tlb->mm);
> >  }
> 
> If we're going to go replace all of these, I wonder if we should start
> doing it more generically.
> 
> 	mm_dec_nr_pgtable(PGTABLE_PTE, tlb->mm)
> 
> or even:
> 
> 	mm_dec_nr_pgtable(PGTABLE_LEVEL1, tlb->mm)
> 
> Instead of having a separate batch of functions for each level.

We don't have this kind of consolidation for any other page table related
helpers. Don't see a reason to start here.

This kind of changes can be part of overal page table privitives redesign
once/if we get there.

But feel free to send patches. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

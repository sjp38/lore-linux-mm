Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A0B736B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 04:25:36 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so5585934wgh.23
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 01:25:35 -0700 (PDT)
Date: Wed, 12 Jun 2013 09:25:28 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 00/11] HugeTLB and THP support for ARM64.
Message-ID: <20130612082528.GA12628@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
 <20130611090714.GA21776@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611090714.GA21776@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, linux-mm@kvack.org

On Tue, Jun 11, 2013 at 10:07:15AM +0100, Steve Capper wrote:
> On Thu, May 23, 2013 at 06:07:47PM +0100, Steve Capper wrote:
> > This series brings huge pages and transparent huge pages to ARM64.
> > The functionality is very similar to x86, and a lot of code that can
> > be used by both ARM64 and x86 is brought into mm to avoid the need
> > for code duplication.
> > 
> > One notable difference from x86 is that ARM64 supports normal pages
> > that are 64KB. When 64KB pages are enabled, huge page and
> > transparent huge pages are 512MB only, otherwise the sizes match
> > x86.
> > 
> > This series applies to 3.10-rc2.
> > 
> > I've tested this under the ARMv8 Fast model and the x86 code has
> > been tested in a KVM guest. libhugetlbfs was used for testing under
> > both architectures.
> > 
> > Changelog:
> > Patch:
> >    * pud_large usage replaced with pud_huge for general hugetlb
> >      code imported into mm.
> >    * comments tidied up for bit swap of PTE_FILE, PTE_PROT_NONE.
> > 
> > RFC v2:
> >    * PROT_NONE support added for HugeTLB and THP.
> >    * pmd_modify implementation fixed.
> >    * Superfluous huge dcache flushing code removed.
> >    * Simplified (and corrected) MAX_ORDER raise for THP && 64KB
> >      pages.
> >    * The MAX_ORDER check in huge_mm.h has been corrected.
> > 
> > ---
> > 
> > Steve Capper (11):
> >   mm: hugetlb: Copy huge_pmd_share from x86 to mm.
> >   x86: mm: Remove x86 version of huge_pmd_share.
> >   mm: hugetlb: Copy general hugetlb code from x86 to mm.
> >   x86: mm: Remove general hugetlb code from x86.
> >   mm: thp: Correct the HPAGE_PMD_ORDER check.
> >   ARM64: mm: Restore memblock limit when map_mem finished.
> >   ARM64: mm: Make PAGE_NONE pages read only and no-execute.
> >   ARM64: mm: Swap PTE_FILE and PTE_PROT_NONE bits.
> >   ARM64: mm: HugeTLB support.
> >   ARM64: mm: Raise MAX_ORDER for 64KB pages and THP.
> >   ARM64: mm: THP support.
> 
> [ ... ]
> 
> Hello,
> I was just wondering if there were any comments on the mm and x86 patches in
> this series, or should I send a pull request for them?
> 
> Catalin has acked the ARM64 ones but we need the x86->mm code move in place
> before the ARM64 code is merged. The idea behind the code move was to avoid
> code duplication between x86 and ARM64 (and ARM).
> 
> Thanks,
> -- 
> Steve

Hello,
Just a polite ping on the above. With the to: field expanded out (apologies if
I was using the incorrect address before).

I was wondering if there were any comments on the x86/mm patches in this
series?

For reference the series can be found archived at:
http://marc.info/?l=linux-mm&m=136932889118818&w=4

Thanks,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

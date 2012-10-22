Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 5E3EC6B0082
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 14:18:45 -0400 (EDT)
Date: Mon, 22 Oct 2012 11:18:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: thp: Set the accessed flag for old pages on
 access fault.
Message-Id: <20121022111843.4406850d.akpm@linux-foundation.org>
In-Reply-To: <20121022103503.GA26619@mudshark.cambridge.arm.com>
References: <1349197151-19645-1-git-send-email-will.deacon@arm.com>
	<20121002150104.da57fa94.akpm@linux-foundation.org>
	<20121017130125.GH5973@mudshark.cambridge.arm.com>
	<20121017.112620.1865348978594874782.davem@davemloft.net>
	<20121017155401.GJ5973@mudshark.cambridge.arm.com>
	<20121018150502.3dee7899.akpm@linux-foundation.org>
	<20121019091016.GA4582@mudshark.cambridge.arm.com>
	<20121019114955.3a0c2b66.akpm@linux-foundation.org>
	<20121022103503.GA26619@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: David Miller <davem@davemloft.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "kirill@shutemov.name" <kirill@shutemov.name>, "aarcange@redhat.com" <aarcange@redhat.com>, "cmetcalf@tilera.com" <cmetcalf@tilera.com>, Steve Capper <Steve.Capper@arm.com>

On Mon, 22 Oct 2012 11:35:03 +0100
Will Deacon <will.deacon@arm.com> wrote:

> On Fri, Oct 19, 2012 at 07:49:55PM +0100, Andrew Morton wrote:
> > On Fri, 19 Oct 2012 10:10:16 +0100
> > Will Deacon <will.deacon@arm.com> wrote:
> > 
> > > On Thu, Oct 18, 2012 at 11:05:02PM +0100, Andrew Morton wrote:
> > > > On Wed, 17 Oct 2012 16:54:02 +0100
> > > > Will Deacon <will.deacon@arm.com> wrote:
> > > > 
> > > > > On x86 memory accesses to pages without the ACCESSED flag set result in the
> > > > > ACCESSED flag being set automatically. With the ARM architecture a page access
> > > > > fault is raised instead (and it will continue to be raised until the ACCESSED
> > > > > flag is set for the appropriate PTE/PMD).
> > > > > 
> > > > > For normal memory pages, handle_pte_fault will call pte_mkyoung (effectively
> > > > > setting the ACCESSED flag). For transparent huge pages, pmd_mkyoung will only
> > > > > be called for a write fault.
> > > > > 
> > > > > This patch ensures that faults on transparent hugepages which do not result
> > > > > in a CoW update the access flags for the faulting pmd.
> > > > 
> > > > Confused.  Where is the arm implementation of update_mmu_cache_pmd()?
> > > 
> > > Right at the end of this patch, which was posted to the ARM list yesterday:
> > > 
> > >   http://lists.infradead.org/pipermail/linux-arm-kernel/2012-October/126387.html
> > 
> > I received and then merged a patch which won't compile!
> 
> Eek, that certainly wasn't intentional and it's compiling fine for me on
> -rc1 and -rc2 for both ARM (no THP) and x86 (with and without THP).
> 
> Please can you send the build failure?
> 
> > Ho hum.  I'll drop
> > mm-thp-set-the-accessed-flag-for-old-pages-on-access-fault.patch and
> > shall assume that you'll sort things out at the appropriate time.
> 
> Happy to sort it out once I work out what's going wrong!

The patch "ARM: mm: Transparent huge page support for LPAE systems" is
not present in linux-next, so this patch ("mm: thp: Set the accessed
flag for old pages on access fault") will not compile?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

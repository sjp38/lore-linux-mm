Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 751306B00F9
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 05:22:43 -0400 (EDT)
Date: Fri, 13 Apr 2012 10:22:40 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] Revert "proc: clear_refs: do not clear reserved pages"
Message-ID: <20120413092240.GC394@mudshark.cambridge.arm.com>
References: <1334250034-29866-1-git-send-email-will.deacon@arm.com>
 <alpine.LSU.2.00.1204121049120.2288@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204121049120.2288@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nicolas Pitre <nico@linaro.org>, akpm@linux-foundation.org

On Thu, Apr 12, 2012 at 06:51:10PM +0100, Hugh Dickins wrote:
> On Thu, 12 Apr 2012, Will Deacon wrote:
> 
> > This reverts commit 85e72aa5384b1a614563ad63257ded0e91d1a620, which was
> > a quick fix suitable for -stable until ARM had been moved over to the
> > gate_vma mechanism:
> > 
> > https://lkml.org/lkml/2012/1/14/55
> > 
> > With commit f9d4861f ("ARM: 7294/1: vectors: use gate_vma for vectors user
> > mapping"), ARM does now use the gate_vma, so the PageReserved check can
> > be removed from the proc code.
> > 
> > Cc: Nicolas Pitre <nico@linaro.org>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Oh, great, I'm glad that worked out: thanks a lot for looking after it,
> Will, and now cleaning up afterwards.
> 
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks, Hugh. I guess it's easiest if Andrew picks this one up as he took
the original patch.

Will

> > ---
> >  fs/proc/task_mmu.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 2b9a760..2d60492 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -597,9 +597,6 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
> >  		if (!page)
> >  			continue;
> >  
> > -		if (PageReserved(page))
> > -			continue;
> > -
> >  		/* Clear accessed and referenced bits. */
> >  		ptep_test_and_clear_young(vma, addr, pte);
> >  		ClearPageReferenced(page);
> > -- 
> > 1.7.4.1
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

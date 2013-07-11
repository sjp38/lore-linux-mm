Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 63EF66B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 08:42:15 -0400 (EDT)
Date: Thu, 11 Jul 2013 13:42:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/16] mm: numa: Do not migrate or account for hinting
 faults on the zero page
Message-ID: <20130711124211.GA2355@suse.de>
References: <1373536020-2799-1-git-send-email-mgorman@suse.de>
 <1373536020-2799-5-git-send-email-mgorman@suse.de>
 <20130711112102.GF25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130711112102.GF25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 01:21:02PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 11, 2013 at 10:46:48AM +0100, Mel Gorman wrote:
> > +++ b/mm/memory.c
> > @@ -3560,8 +3560,13 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	set_pte_at(mm, addr, ptep, pte);
> >  	update_mmu_cache(vma, addr, ptep);
> >  
> > +	/*
> > +	 * Do not account for faults against the huge zero page. The read-only
> 
> s/huge //
> 

Whoops, thanks. Guess which comment I wrote first?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

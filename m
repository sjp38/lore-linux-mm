Date: Wed, 28 May 2008 10:40:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 03/23] hugetlb: modular state
Message-ID: <20080528084006.GA2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.408189000@nick.local0.net> <20080527164426.GC20709@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080527164426.GC20709@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 09:44:26AM -0700, Nishanth Aravamudan wrote:
> On 26.05.2008 [00:23:20 +1000], npiggin@suse.de wrote:
> > 
> >  	might_sleep();
> > -	for (i = 0; i < HPAGE_SIZE/PAGE_SIZE; i++) {
> > +	for (i = 0; i < 1 << huge_page_order(h); i++) {
> 
> So it seems like most (not quite all) users of huge_page_order(h) don't
> actually care about the order, per se, but want some sense of the
> underlying pagesize. Either pages_per_huge_page() or huge_page_size().
> 
> So perhaps it would be sensible to have the helpers defined as such?
> 
> huge_page_size(h) -> size in bytes of huge page (corresponds to what was
> HPAGE_SIZE), which is what I think you currently have
> 
> and
> 
> pages_per_huge_page(h) -> number of base pages per huge page
> (corresponds to HPAGE_SIZE / PAGE_SIZE)
> 
> ?

I think pages_per_huge_page would be reasonable, yes.

 
> Also, I noticed that this caller has no parentheses, but the other one
> does, for (1 << huge_page_order(h))
> 
> Neither are huge issues and the first can be a clean-up patch from me,
> so
> 
> Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks... I'll do pages_per_huge_page(), it won't be much work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

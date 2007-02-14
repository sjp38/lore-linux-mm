Date: Wed, 14 Feb 2007 14:49:49 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
In-Reply-To: <Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0702141448170.3326@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
 <20070213000411.a6d76e0c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
 <20070214142432.a7e913fa.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Christoph Lameter wrote:

> > This function will return zero.  Which I think we'll happen to handle OK.
> 
> One would expect the function to return 10. The 10 pages are on the LRU.
> If we really have zero dirtyable pages then we will get a division by 
> zero problem.

Well we do not have the division by zero problem due to this 
expression that really should also use available_memory

       unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
                                global_page_state(NR_ANON_PAGES)) * 100) /
                                        vm_total_pages;

If we would change the basis here too (which is probably a good thing to 
do) then we may have the division by zero issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

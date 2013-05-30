Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 4FB766B0078
	for <linux-mm@kvack.org>; Thu, 30 May 2013 07:03:29 -0400 (EDT)
Date: Thu, 30 May 2013 13:03:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB and PTE coherency during munmap
Message-ID: <20130530110321.GO12193@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <51A6DDF5.2000406@synopsys.com>
 <20130530065627.GL12193@twins.programming.kicks-ass.net>
 <51A6F923.6010709@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51A6F923.6010709@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

On Thu, May 30, 2013 at 12:30:51PM +0530, Vineet Gupta wrote:
> On 05/30/2013 12:26 PM, Peter Zijlstra wrote:
> > On Thu, May 30, 2013 at 10:34:53AM +0530, Vineet Gupta wrote:
> >> On 05/29/2013 11:21 PM, Peter Zijlstra wrote:
> >>
> >> BTW, since we are on the topic, it seems that we are missing tlb_fast_mode() in
> >> one spot - unless it is tied to rcu table free stuff.
> >>
> >> -------------->
> >> From: Vineet Gupta <vgupta@synopsys.com>
> >> Date: Thu, 30 May 2013 10:25:30 +0530
> >> Subject: [PATCH] mm: tlb_fast_mode check missing in tlb_finish_mmu()
> >>
> >> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> >> ---
> >>  mm/memory.c |    3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index d9d5fd9..569ffe1 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -269,6 +269,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long
> >> start, unsigned long e
> >>      /* keep the page table cache within bounds */
> >>      check_pgt_cache();
> >>  
> >> +    if (tlb_fast_mode(tlb))
> >> +        return;
> >> +
> >>      for (batch = tlb->local.next; batch; batch = next) {
> >>          next = batch->next;
> >>          free_pages((unsigned long)batch, 0);
> > Yes I think that is possible. It would shrink the code a little when
> > fast_mode was unconditionally 1 -- ie. simple UP ;-).
> 
> Exactly ! Can you please revert with a Reviewed-by/Acked-by so I can formally send
> it over to linux-mm list.

s/revert/reply/?

Acked-by: Peter Zijlstra <peterz@infradead.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

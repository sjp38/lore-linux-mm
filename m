Date: Fri, 10 Feb 2006 23:30:37 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] Removing page->flags
Message-ID: <20060211053037.GA3331@dmt.cnet>
References: <1139381183.22509.186.camel@localhost> <43E9DBE8.8020900@yahoo.com.au> <aec7e5c30602081835s8870713qa40a6cf88431cad1@mail.gmail.com> <43EAC2CE.2010108@yahoo.com.au> <aec7e5c30602082119v4127aa92ga3c9d9ba6dee0378@mail.gmail.com> <43EAD524.6020105@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43EAD524.6020105@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>, Peter Zijlstra <peter@programming.kicks-ass.net>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 09, 2006 at 04:37:40PM +1100, Nick Piggin wrote:
> Magnus Damm wrote:
> 
> >But introducing a second page->flags is out of the question, and
> >breaking out flags and placing a pointer to them in the node data
> >structure will introduce more cache misses. So it is probably not
> >worth it.
> >
> 
> Yep. Even then, you can't simply have a single non-atomic flags word,
> unless _all_ flags are protected by the same lock.
> 
> >>
> >>It seems pretty unlikely that we'll get a pluggable replacement
> >>policy in mainline any time soon though.
> >
> >
> >So, do you think it is more likely that a ClockPro implementation will
> >be accepted then? Or is Linux "doomed" to LRU forever?
> >
> 
> I think (hope) that Linux eventually (if slowly) moves toward the best
> implementation available. I just don't think there will be sufficient
> justification for a pluggable page reclaim infrastructure in the mainline
> kernel.

Hi Nick,

There is no such thing as "best implementation available" given that
page replacement policy is nothing more than a set of heuristics
assuming certain characteristics of the underlying workload, and
optimizing for that.

Please refer to 
http://programming.kicks-ass.net/kernel-patches/clockpro-2/dev/2.6.16-rc2-1/

Peter's patchset implements a pluggable page reclaim infrastructure
which is used by CLOCK-Pro and CART. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

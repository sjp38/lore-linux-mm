From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Thu, 9 Mar 2006 13:30:13 +1100
References: <200603081013.44678.kernel@kolivas.org> <20060308222404.GA4693@elf.ucw.cz> <440F9154.2080909@yahoo.com.au>
In-Reply-To: <440F9154.2080909@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200603091330.14396.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Mar 2006 01:22 pm, Nick Piggin wrote:
> Pavel Machek wrote:
> >On Ut 07-03-06 16:05:15, Andrew Morton wrote:
> >>Why do you want that?
> >>
> >>If prefetch is doing its job then it will save the machine from a pile of
> >>major faults in the near future.  The fact that the machine happens
> >
> >Or maybe not.... it is prefetch, it may prefetch wrongly, and you
> >definitely want it doing nothing when system is loaded.... It only
> >makes sense to prefetch when system is idle.
>
> Right. Prefetching is obviously going to have a very low work/benefit,
> assuming your page reclaim is working properly, because a) it doesn't
> deal with file pages, and b) it is doing work to reclaim pages that
> have already been deemed to be the least important.
>
> What it is good for is working around our interesting VM that apparently
> allows updatedb to swap everything out (although I haven't seen this
> problem myself), and artificial memory hogs. By moving work to times of
> low cost. No problem with the theory behind it.
>
> So as much as a major fault costs in terms of performance, the tiny
> chance that prefetching will avoid it means even the CPU usage is
> questionable. Using sched_yield() seems like a hack though.

Yeah it's a hack alright. Funny how at last I find a place where yield does 
exactly what I want and because we hate yield so much noone wants me to use 
it all.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

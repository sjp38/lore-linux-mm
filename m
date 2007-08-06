Date: Mon, 6 Aug 2007 19:21:29 +1000 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <Pine.LNX.4.64.0708051916430.6905@asgard.lang.hm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <997038.92524.qm@web53809.mail.re2.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Rene Herman <rene.herman@gmail.com>, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--- david@lang.hm wrote:

> On Mon, 6 Aug 2007, Nick Piggin wrote:
> 
> > david@lang.hm wrote:
> >>  On Sun, 29 Jul 2007, Rene Herman wrote:
> >> 
> >> >  On 07/29/2007 01:41 PM, david@lang.hm wrote:
> >> > 
> >> > >  I agree that tinkering with the core VM code
> should not be done 
> >> > >  lightly,
> >> > >   but this has been put through the proper
> process and is stalled with 
> >> > >   no
> >> > >   hints on how to move forward.
> >> > 
> >> > 
> >> >  It has not. Concerns that were raised (by
> specifically Nick Piggin) 
> >> >  weren't being addressed.
> >>
> >>
> >>  I may have missed them, but what I saw from him
> weren't specific issues,
> >>  but instead a nebulous 'something better may
> come along later'
> >
> > Something better, ie. the problems with page
> reclaim being fixed.
> > Why is that nebulous?
> 
> becouse that doesn't begin to address all the
> benifits.

What do you mean "address the benefits"? What I want
to address is the page reclaim problems.


> the approach of fixing page reclaim and updatedb is
> pretending that if you 
> only do everything right pages won't get pushed to
> swap in the first 
> place, and therefor swap prefetch won't be needed.

You should read what I wrote.

Anyway, the fact of the matter is that there are still
fairly significant problems with page reclaim in this
workload which I would like to see fixed.

I personally still think some of the low hanging fruit
*might* be better fixed before swap prefetch gets
merged, but I've repeatedly said I'm sick of getting
dragged back into the whole debate so I'm happy with
whatever Andrew decides to do with it.

I think it is sad to turn it off for laptops, if it
really makes the "desktop" experience so much better.
Surely for _most_ workloads we should be able to
manage 1-2GB of RAM reasonably well.

 
> this completely ignores the use case where the
> swapping was exactly the 
> right thing to do, but memory has been freed up from
> a program exiting so 
> that you couldnow fill that empty ram with data that
> was swapped out.

Yeah. However, merging patches (especially when
changing heuristics, especially in page reclaim) is
not about just thinking up a use-case that it works
well for and telling people that they're putting their
heads in the sand if they say anything against it.
Read this thread and you'll find other examples of
patches that have been around for as long or longer
and also have some good use-cases and also have not
been merged.



      ____________________________________________________________________________________
Yahoo!7 Mail has just got even bigger and better with unlimited storage on all webmail accounts. 
http://au.docs.yahoo.com/mail/unlimitedstorage.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

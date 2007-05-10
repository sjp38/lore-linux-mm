From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Date: Thu, 10 May 2007 11:34:33 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705100928.34056.kernel@kolivas.org> <464261B5.6030809@yahoo.com.au>
In-Reply-To: <464261B5.6030809@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705101134.34350.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 10 May 2007 10:05, Nick Piggin wrote:
> Con Kolivas wrote:
> > Well how about that? That was the difference with a swap _file_ as I
> > said, but I went ahead and checked with a swap partition as I used to
> > have. I didn't notice, but somewhere in the last few months, swap
> > prefetch code itself being unchanged for a year, seems to have been
> > broken by other changes in the vm and it doesn't even start up
> > prefetching often and has stale swap entries in its list. Once it breaks
> > like that it does nothing from then on. So that leaves me with a quandry
> > now.
> >
> >
> > Do I:
> >
> > 1. Go ahead and find whatever breakage was introduced and fix it with
> > hopefully a trivial change
> >
> > 2. Do option 1. and then implement support for yet another kernel feature
> > (cpusets) that will be used perhaps never with swap prefetch [No Nick I
> > don't believe you that cpusets have anything to do with normal users on a
> > desktop ever; if it's used on a desktop it will only be by a kernel
> > developer testing the cpusets code].
> >
> > or
> >
> > 3. Dump swap prefetch forever and ignore that it ever worked and was
> > helpful and was a lot of work to implement and so on.
> >
> >
> > Given that even if I do 1 and/or 2 it'll still be blocked from ever going
> > to mainline I think the choice is clear.
> >
> > Nick since you're personally the gatekeeper for this code, would you like
> > to make a call? Just say 3 and put me out of my misery please.
>
> I'm not the gatekeeper and it is completely up to you whether you want
> to work on something or not... but I'm sure you understand where I was
> coming from when I suggested it doesn't get merged yet.

No matter how you spin it, you're the gatekeeper.

> You may not believe this, but I agree that swap prefetching (and
> prefetching in general) has some potential to help desktop workloads :).
> But it still should go through the normal process of being tested and
> questioned and having a look at options for first improving existing
> code in those problematic cases.

Not this again? Proof was there ages ago that it helped and no proof that it 
harmed could be found yet you cunningly pretend it never existed. It's been 
done to death and I'm sick of this.

> Once that process happens and it is shown to work nicely, etc., then I
> would not be able to (or want to) keep it from getting merged.
>
> As far as cpusets goes... if your code goes in last, then you have to
> make it work with what is there, as a rule. People are using cpusets
> for memory resource control, which would have uses on a desktop system.
> It is just a really bad precedent to set, having different parts of the
> VM not work correctly together. Even if you made them mutually
> exclusive CONFIG_ options, that is still not a very nice solution.

That's as close to a 3 as I'm likely to get out of you.

Andrew you'll be relieved to know I would like you to throw swap prefetch and 
related patches into the bin. Thanks.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
Date: Thu, 10 May 2007 09:28:33 +1000
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <200705042210.15953.kernel@kolivas.org> <200705051842.32328.kernel@kolivas.org>
In-Reply-To: <200705051842.32328.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705100928.34056.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: ck list <ck@vds.kolivas.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 05 May 2007 18:42, Con Kolivas wrote:
> On Friday 04 May 2007 22:10, Con Kolivas wrote:
> > On Friday 04 May 2007 18:52, Ingo Molnar wrote:
> > > agreed. Con, IIRC you wrote a testcase for this, right? Could you
> > > please send us the results of that testing?
> >
> > Yes, sorry it's a crappy test app but works on 32bit. Timed with prefetch
> > disabled and then enabled swap prefetch saves ~5 seconds on average
> > hardware on this one test case. I had many users try this and the results
> > were between 2 and 10 seconds, but always showed a saving on this
> > testcase. This effect easily occurs on printing a big picture, editing a
> > large file, compressing an iso image or whatever in real world workloads.
> > Smaller, but much more frequent effects of this over the course of a day
> > obviously also occur and do add up.
>
> Here's a better swap prefetch tester. Instructions in file.
>
> Machine with 2GB ram and 2GB swapfile
>
> Prefetch disabled:
> ./sp_tester

> Timed portion 53397 milliseconds
>
> Enabled:
> ./sp_tester

> Timed portion 26351 milliseconds
>
> Note huge time difference.

Well how about that? That was the difference with a swap _file_ as I said, but 
I went ahead and checked with a swap partition as I used to have. I didn't 
notice, but somewhere in the last few months, swap prefetch code itself being 
unchanged for a year, seems to have been broken by other changes in the vm 
and it doesn't even start up prefetching often and has stale swap entries in 
its list. Once it breaks like that it does nothing from then on. So that 
leaves me with a quandry now.


Do I:

1. Go ahead and find whatever breakage was introduced and fix it with 
hopefully a trivial change

2. Do option 1. and then implement support for yet another kernel feature 
(cpusets) that will be used perhaps never with swap prefetch [No Nick I don't 
believe you that cpusets have anything to do with normal users on a desktop 
ever; if it's used on a desktop it will only be by a kernel developer testing 
the cpusets code].

or

3. Dump swap prefetch forever and ignore that it ever worked and was helpful 
and was a lot of work to implement and so on.


Given that even if I do 1 and/or 2 it'll still be blocked from ever going to 
mainline I think the choice is clear.

Nick since you're personally the gatekeeper for this code, would you like to 
make a call? Just say 3 and put me out of my misery please.

-- 
-ck

P.S. Ingo, thanks (and sorry) for your involvement here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

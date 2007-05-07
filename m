Message-ID: <463F353B.1040405@tmr.com>
Date: Mon, 07 May 2007 10:18:35 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: swap-prefetch: 2.6.22 -mm merge plans
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070503155407.GA7536@elte.hu> <463AE1EB.1020909@yahoo.com.au> <20070504085201.GA24666@elte.hu>
In-Reply-To: <20070504085201.GA24666@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Con Kolivas <kernel@kolivas.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>> i'm wondering about swap-prefetch:
> 
>> Being able to config all these core heuristics changes is really not 
>> that much of a positive. The fact that we might _need_ to config 
>> something out, and double the configuration range isn't too pleasing.
> 
> Well, to the desktop user this is a speculative performance feature that 
> he is willing to potentially waste CPU and IO capacity, in expectation 
> of better performance.
> 
> On the conceptual level it is _precisely the same thing as regular file 
> readahead_. (with the difference that to me swapahead seems to be quite 
> a bit more intelligent than our current file readahead logic.)
> 
> This feature has no API or ABI impact at all, it's a pure performance 
> feature. (besides the trivial sysctl to turn it runtime on/off).
> 
>> Here were some of my concerns, and where our discussion got up to.

	[...snip...]

> i see no real problem here. We've had heuristics for a _long_ time in 
> various areas of the code. Sometimes they work, sometimes they suck.
> 
> the flow of this is really easy: distro looking for a feature edge turns 
> it on and announces it, if the feature does not work out for users then 
> user turns it off and complains to distro, if enough users complain then 
> distro turns it off for next release, upstream forgets about this 
> performance feature and eventually removes it once someone notices that 
> it wouldnt even compile in the past 2 main releases. I see no problem 
> here, we did that in the past too with performance features. The 
> networking stack has literally dozens of such small tunable things which 
> get experimented with, and whose defaults do get tuned carefully. Some 
> of the knobs help bandwidth, some help latency.
> 
I haven't looked at this code since it first came out and didn't impress 
me, but I think it would be good to get the current version in. However, 
when you say "user turns it off" I hope you mean "in /proc/sys with a 
switch or knob" and not by expecting people to recompile and install a 
kernel. Then it might take a little memory but wouldn't do something 
undesirable.

Note: I had no bad effect from the code, it just didn't feel faster. On 
a low memory machine it might help. Of course I have wanted to have a 
hard limit on memory used for i/o buffers, just to avoid swapping 
programs to make room for i/o, so to some extent I feel as if this is a 
fix for a problem we shouldn't have.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

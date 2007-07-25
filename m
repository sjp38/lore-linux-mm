Message-ID: <46A75062.1050809@gmail.com>
Date: Wed, 25 Jul 2007 15:30:10 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <46A57068.3070701@yahoo.com.au>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>	 <46A6DFFD.9030202@gmail.com>	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com> <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
In-Reply-To: <5c77e14b0707250353r48458316x5e6adde6dbce1fbd@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jos Poortvliet <jos@mijnkamer.nl>
Cc: Ingo Molnar <mingo@elte.hu>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Valdis.Kletnieks@vt.edu, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 07/25/2007 12:53 PM, Jos Poortvliet wrote:

> On 7/25/07, *Rene Herman* <rene.herman@gmail.com 
> <mailto:rene.herman@gmail.com>> wrote:

>> Also note I'm not against swap prefetch or anything. I don't use it and
>> do not believe I have a pressing need for it, but do suspect it has 
>> potential to make quite a bit of difference on some things -- if only
>> to drastically reduce seeks if it means it's swapping in larger chunks
>> than a randomly faulting program would.
> 
> I wonder what your hardware is. Con talked about the diff in hardware 
> between most endusers and the kernel developers. 

I'm afraid you will need to categorize me more as an innocent bystander than 
a kernel developer and, as such, I have an endusery x86 with 768M (but I 
still think of myself as one of the cool kids!)

> Yes, swap prefetch doesn't help if you have 3 GB ram, but it DOES do a
> lot on a 256 mb laptop...

Rather, it does not help if you are not swapping or idling. Probably largely 
due to me being a rather serial person I seem to never even push my git tree 
from cache. Hence my belief that "I don't have a pressing need for it".

Taking a laptop as an example is interesting in itself by the way since a 
spundown disk (most applicable to laptops) is an argument against swap 
prefetch even when idle and when I'm not mistaken the feature actually 
disables itself when the machine's set to laptop mode...

> After using OO.o, the system continues to be slow for a long time. With
> swap prefetch, it's back up speed much faster. Con has showed a benchmark
> for this with speedups of 10 times and more, users mentioned they liked
> it.

After using and quiting OO.o. If you simply don't have any memory free to 
prefetch into swap prefetch won't help any. The fact that it helps the case 
of OO.o having pushed out firefox is fairly obvious.

> Nick has been talking about 'fixing the updatedb thing' for years now, no
> patch yet. Besides, he won't fix OO.o nor all other userspace stuff - so
> actually, he does NOT even promise an alternative. Not that I think
> fixing updatedb would be cool, btw - it sure would, but it's no reason
> not to include swap prefetch - it's mostly unrelated.

Well, the trouble at least to some is that they indeed seem to be rather 
unrelated. Why does the updatedb run even cause swapout? (itself ofcourse a 
pre-condition for swap-prefetch to help).

> I think everyone with >1 gb ram should stop saying 'I don't need it' 
> because that's obvious for that hardware. Just like ppl having a dual- 
> or quadcore shouldn't even talk about scheduler interactivity stuff...

Actually, interactivity is largely about latency and latency is largely or 
partly independent of CPU speed -- if something's keeping the system from 
scheduling for too long it's likely that it's hogging the CPU for a fixed 
number of usecs and those pass in the same amount of time on all CPUs (we 
hope...).

But that's a tangent anyway. I'm just glad that I get to say that I believe 
I don't need it with my 768M!

> Apparently, it didn't get in yet - and I find it hard to believe Andrew 
> holds swapprefetch for reasons like the above. So it must be something 
> else.
> 
> Nick is saying tests have already proven swap prefetch to be helpfull, 
> that's not the problem. He calls the requirements to get in 'fuzzy'. OK.
> Beer is fuzzy, do we need to offer beer to someone? If Andrew promises 
> to come to FOSDEM again next year, I'll offer him a beer, if that 
> helps... Anything else? A nice massage?

Personally I'd go for sexual favours directly (but then again, I always do).

But please also note that I even _literally_ said above that I myself am not 
against swap-prefetch or anything and yet I get what appears to be an least 
somewhat adversary rant directed at me. Which in itself is fine, but not too 
helpful...

Nick Piggin is the person to convince it seems and if I've read things right 
(I only stepped into this thing at the updatedb mention, so maybe I haven't) 
his main question is _why_ the hell it helps updatedb. As long as you don't 
know this, then even a solution that helps could be papering over a problem 
which you'd much rather fix at the root rather than at the symptom.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

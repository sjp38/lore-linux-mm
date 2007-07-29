Message-ID: <46AC6771.8080000@gmail.com>
Date: Sun, 29 Jul 2007 12:09:53 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm> <46AAEDEB.7040003@gmail.com> <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm> <46AB166A.2000300@gmail.com> <Pine.LNX.4.64.0707281349540.32476@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0707281349540.32476@asgard.lang.hm>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 07/28/2007 11:00 PM, david@lang.hm wrote:

>> many -mm users use it anyway? He himself said he's not convinced of 
>> usefulness having not seen it help for him (and notice that most 
>> developers are also users), turned it off due to it annoying him at 
>> some point and hasn't seen a serious investigation into potential 
>> downsides.
> 
> if that was the case then people should be responding to the request to 
> get it merged with 'but it caused problems for me when I tried it'
> 
> I haven't seen any comments like that.

So you're saying Andrew did not say that? You're jumping to the conclusion 
that I am saying that it's causing problems.

>>>  that the only significant con left is the potential to mask other
>>>  problems.
>>
>> Which is not a madeup issue, mind you. As an example, I just now tried 
>> GNU locate and saw it's a complete pig and specifically unsuitable for 
>> the low memory boxes under discussion. Upon completion, it actually 
>> frees enough memory that swap-prefetch _could_ help on some boxes, 
>> while the real issue is that they should first and foremost dump GNU 
>> locate.
> 
> I see the conclusion as being exactly the opposite.

And now you do it again :-) There is no conclusion -- just the inescapable 
observation that swap-prefetch was (or may have been) masking the problem of 
GNU locate being a program that noone in their right mind should be using.

> so there is a legitimate situation where swap-prefetch will help 
> significantly, what is the downside that prevents it from being 
> included?

People being unconvinced it helps all that much, no serious investigation 
into possible downsides and no consideration of alternatives is three I've 
personally heard.

You don't want to merge a conceptually core VM feature if you're not really 
convinced. It's not a part of the kernel you can throw a feature into like 
you could some driver saying "ah, heck, if it makes someone happy" since 
everything in the VM ends up interacting -- that in fact is actually the 
hard part of VM as far as I've seen it.

And in this situation the proposed feature is something that "papers over a 
problem" by design -- where it could certainly be that the problem is not 
solveable in another way simply due to the kernel not growing the possiblity 
to read user's minds anytime soon (which some might even like to rephrase as 
"due to no problem existing") but that this gets people a bit anxious is not 
surprising.

> I've seen it mentioned that there is still a maintainer but I missed who
> it is, but I haven't seen any concerns that can be addressed, they all 
> seem to be 'this is a core concept, people need to think about it' or 
> 'but someone may find a better answer in the future' type of things. it's
> impossible to address these concerns directly.

So do it indirectly. But please don't just say "it help some people (not me 
mind you!) so merge it and if you don't it's all just politics and we can't 
do anything about it anyway". Because that's mostly what I've been hearing.

And no, I'm not subscribed to any ck mailinglists nor do I hang around its 
IRC community which will can account for part of that. I expect though that 
the same holds for the people that actually matter in this, such as Andrew 
Morton and Nick Piggin.

-- 1: people being unconvinced it helps all that much

At least partly caused by the updatedb i/dcache red herring that infected 
this issue. Also, at the point VM  pressure has mounted high enough to cause 
enough to be swapped out to give you a bad experience, a lot of other things 
have been dropped already as well.

It's unsurprising though that it would for example help the issue of 
openoffice with a large open spreadsheet having been thrown out overnight 
meaning it's a matter of deciding whether or not this is an important enough 
issue to fix inside the VM with something like swap-prefetch.

Personally -- no opinion, I do not experience the problem (I even switch off 
the machine at night and do not run cron at all).

-- 2: no serious investigation into possible downsides

Swap-prefetch tries hard to be as free as possible and it seems to largely 
be succeeding at that. Thing that (obviously -- as in I wouldn't want to 
state it's the only possible worry anyone could have left) remains is the 
"papering over effect" it has by design that one might not care for.

-- 3: no serious consideration of possible alternatives

Tweaking existing use-oce logic is one I've heard but if we consider the 
i/dcache issue dead, I believe that one is as well. Going to userspace is 
another one. Largest theoretical potential. I myself am extremely sceptical 
about the Linux userland, and largely equate it with "smallest _practical_ 
potential" -- but that might just be me.

A larger swap granularity, possible even a self-training granularity. Up to 
now, seeks only get costlier and costlier with respect to reads with every 
generation of disk (flash would largely overcome it though) and doing more 
in one read/write _greatly_ improves throughput, maybe up to the point that 
swap-prefetch is no longer very useful. I myself don't know about the 
tradeoffs involved.

Any other alternatives?

Any 4th and higher points?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

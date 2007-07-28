Date: Sat, 28 Jul 2007 14:00:21 -0700 (PDT)
From: david@lang.hm
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
In-Reply-To: <46AB166A.2000300@gmail.com>
Message-ID: <Pine.LNX.4.64.0707281349540.32476@asgard.lang.hm>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
 <20070727030040.0ea97ff7.akpm@linux-foundation.org> <1185531918.8799.17.camel@Homer.simpson.net>
 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
 <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm> <46AAEDEB.7040003@gmail.com>
 <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm> <46AB166A.2000300@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 28 Jul 2007, Rene Herman wrote:

> On 07/28/2007 10:55 AM, david@lang.hm wrote:
>
>>  it looks to me like unless the code was really bad (and after 23 months in
>>  -mm it doesn't sound like it is)
>
> Not to sound pretentious or anything but I assume that Andrew has a fairly 
> good overview of exactly how broken -mm can be at times. How many -mm users 
> use it anyway? He himself said he's not convinced of usefulness having not 
> seen it help for him (and notice that most developers are also users), turned 
> it off due to it annoying him at some point and hasn't seen a serious 
> investigation into potential downsides.

if that was the case then people should be responding to the request to 
get it merged with 'but it caused problems for me when I tried it'

I haven't seen any comments like that.

>>  that the only significant con left is the potential to mask other
>>  problems.
>
> Which is not a madeup issue, mind you. As an example, I just now tried GNU 
> locate and saw it's a complete pig and specifically unsuitable for the low 
> memory boxes under discussion. Upon completion, it actually frees enough 
> memory that swap-prefetch _could_ help on some boxes, while the real issue is 
> that they should first and foremost dump GNU locate.

I see the conclusion as being exactly the opposite.

here is a workload with some badly designed userspace software that the 
kernel can make much more pleasent for users.

arguing that users should never use badly designed software in userspace 
doesn't seem like an argument that will gain much traction. I'm not saying 
the kernel needs to fix the software itself (ala the sched_yeild issues), 
but the kernel should try and keep such software from hurting the rest of 
the system where it can.

in this case it can't help it while the bad software is running, but it 
could minimize the impact after it finishes.

>>  however there are many legitimate cases where it is definantly dong the
>>  right thing (swapout was correct in pushing out the pages, but now the
>>  cause of that preasure is gone). the amount of benifit from this will vary
>>  from situation to situation, but it's not reasonable to claim that this
>>  provides no benifit (you have benchmark numbers that show it in synthetic
>>  benchmarks, and you have user reports that show it in the real-worlk)
>
> I certainly would not want to argue anything of the sort no. As said a few 
> times, I agree that swap-prefetch makes sense and has at least the potential 
> to help some situations that you really wouldnt even want to try and fix any 
> other way, simply because nothing's broken.

so there is a legitimate situation where swap-prefetch will help 
significantly, what is the downside that prevents it from being included? 
(reading this thread it sometimes seems like the downside is that updatedb 
shouldn't cause this problem and so if you fixed updatedb there wold be no 
legitimate benifit, or alturnatly this patch doesn't help updatedb so 
there's no legitimate benifit)

>>  there are lots of things in the kernel who's job is to pre-fill the memroy
>>  with data that may (or may not) be useful in the future. this is just
>>  another method of filling the cache. it does so my saying "the user
>>  wanted these pages in the recent past, so it's a reasonable guess to say
>>  that the user will want them again in the future"
>
> Well, _that_ is what the kernel is already going to great lengths at doing, 
> and it decided that those pages us poor overnight OO.o users want in in the 
> morning weren't reasonable guesses. The kernel also won't any time soon be 
> reading our minds, so any solution would need either user intervention (we 
> could devise a way to tell the kernel "hey ho, I consider these pages to be 
> very important -- try not to swap them out" possible even with a "and if you 
> do, please pull them back in when possible") or we can let swap-prefetch do 
> the "just in case" thing it is doing.

it's not that they shouldn't have been swapped out (they should have 
been), it's that the reason they were swapped out no longer exists.

> While swap-prefetch may not be the be all end all of solutions I agree that 
> having a machine sit around with free memory and applications in swap seems 
> not too useful if (as is the case) fetched pages can be dropped immediately 
> when it turns out swap-prefetch made the wrong decision.
>
> So that's for the concept. As to implementation, if I try and look at the 
> code, it seems to be trying hard to really be free and as such, potential 
> downsides seem limited. It's a rather core concept though and as such needs 
> someone with a _lot_ more VM clue to ack. Sorry for not knowing, but who's 
> maintaining/submitting the thing now that Con's not? He or she should 
> preferably address any concerns it seems.

I've seen it mentioned that there is still a maintainer but I missed who 
it is, but I haven't seen any concerns that can be addressed, they all 
seem to be 'this is a core concept, people need to think about it' or 'but 
someone may find a better answer in the future' type of things. it's 
impossible to address these concerns directly.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

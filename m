From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 1 Jun 2006 13:21:01 +1000 (EST)
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
In-Reply-To: <447CFEAA.5070206@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0606011313350.29379@weill.orchestra.cse.unsw.EDU.AU>
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
 <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
 <447C055A.9070906@sgi.com> <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
 <447CFEAA.5070206@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jes Sorensen <jes@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 May 2006, Nick Piggin wrote:

> Paul Cameron Davies wrote:
>
>> Hi Jes
>> 
>> I concede that I am acutely aware that 3.5% is just too high,  but we know 
>> which abstractions are causing the problems.
>> 
>> We will hope to nail down some of these problems in the next few weeks
>> and then feed again.
>> 
>> What level of degradation in peformance in acceptable (if any)?
>
>
> For upstream inclusion? negative degradation, I'd assume: you're adding
> significant complexity so there has to be some justification for it...

Our long term goal is upstream inclusion.  We are planning to release
early and release often to get feedback and exposure.  We want to bring
around the people that don't have a vested interest in cleanly accessing
the page tables, and get early input into the direction the interface
should take.

> And unless it is something pretty significant, I'd almost bet that Linus,
> if nobody else, will veto it. Our radix-tree v->p data structure is
> fairly clean, performant, etc. It matches the logical->physical radix
> tree data structure we use for pagecache as well.

Being able to change the page table on a 64 bit machine will
be a huge advantage into the future when applications really start to
make use of the 64 bit address space.  The current trie (multi level
page table - MLPT) is not going to perform against more
sophisticated data structures in a sparsely occupied 64 bit address space
At UNSW we are experimenting with different page tables.  We have
replaced the MLPT in Linux with a GPT (guarded page table), running
on an older kernel. The GPT is essentially an unconstrained radix tree (a
specialed MLPT).

GPTs are naturally suited to page table sharing and the seamless
implementation of Superpages. (please refer to Liedtke's paper,
Address Space Sparsity and fine granularity, ACM Operating Systems
Review, vol 29, pp87-90, January 1995).

We are looking to provide alternate page table options in Linux
to enable Linux to continue to boast about its scalability
as an operating system.  The MLPT is not going to scale from the 32
bit address space to the 64 bit address space.  Unfortunately
some concession may need to be made by some architectures to support this.

> BTW. I reckon your performance problems are due to indirect function
> calls.
Thanks.  This is certainly a large part of the performance problem.
The problem is, thus far it is the most efficient solution I have come up
with.

Cheers

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

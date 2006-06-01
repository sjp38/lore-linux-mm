From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 1 Jun 2006 16:35:49 +1000 (EST)
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
In-Reply-To: <Pine.LNX.4.64.0605310412530.5488@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0606011632400.25647@weill.orchestra.cse.unsw.EDU.AU>
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU>
 <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
 <447C055A.9070906@sgi.com> <Pine.LNX.4.62.0605311111020.13018@weill.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.64.0605310412530.5488@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jes Sorensen <jes@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 May 2006, Hugh Dickins wrote:

> On Wed, 31 May 2006, Paul Cameron Davies wrote:
>>
>> What level of degradation in peformance in acceptable (if any)?
>
> None.  What is the point in slowing it down, even on the architecture
> you are targeting, while making it all more complicated, moving
> significant code around from the .cs where we expect it into .hs?

The PTI (page table interface) will give a small performance hit,
but we believe that when the MLPT is replaced with some other
implementation, for example the GPT (guarded page table), that
a better overall performance will be achieved.

In particular, this will be true for apps with large memory
requirements on 64-bit architectures.

We have access to some papers discussing the problems that will
occur when large memory spaces are more commonly used, but
unfortunately there is no URL to directly access them.
We do have a paper that discusses variable radix page tables
(which is a GPT by another name) found here:

www.ertos.nicta.com.au/publications/papers/Szmajda_Heiser_03.pdf

As a pragmatist, I agree that it is of real concern that the
page table interface would slow down commonly-used architectures.
However, current performance depends on the kernel being
organised to suit the MLPT implementation. That is likely to
prevent efficient use of large memory spaces in the future.

Directly accessing the VM data structure works well at the moment.
In the near future, it is likely that many systems will want to
work with large amounts of memory, and the optimisations that
work well now will not work well with those systems.

> And please, next time, make sure the patches can actually be applied:
> your mailer (pine) messed with the whitespace - quell-flowed-text is,
> I think, the feature you need to add, but mail yourself the patches
> first as a test to make sure they can be applied by recipients.
Sorry, thanks for the tip.

Cheers

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

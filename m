Message-ID: <45B18344.5020507@yahoo.com.au>
Date: Sat, 20 Jan 2007 13:49:40 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>	 <45B0DB45.4070004@linux.vnet.ibm.com>	 <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>	 <45B112B6.9060806@linux.vnet.ibm.com>	 <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>	 <45B17D6D.2030004@yahoo.com.au> <8bd0f97a0701191835y49a61e7jb65a3b63f906ca56@mail.gmail.com>
In-Reply-To: <8bd0f97a0701191835y49a61e7jb65a3b63f906ca56@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

Mike Frysinger wrote:
> On 1/19/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> Luckily, there are actually good, robust solutions for your higher
>> order allocation problem. Do higher order allocations at boot time,
>> modifiy userspace applications, or set up otherwise-unused, or easily
>> reclaimable reserve pools for higher order allocations. I don't
>> understand why you are so resistant to all of these approaches?
> 
> 
> in a nutshell ...
> 
> the idea is to try and generalize these things
> 
> your approach involves tweaking each end solution to maximize the 
> performance

Maybe, if you are talking about my advice to fix userspace... but you
*are* going to contribute those changes back for the nommu community
to use, right? So the end result of that is _not_ actually tweaking the
end solutions.

But actually, if you take the reserved pool approach, then that will
work fine, in-kernel, and it is something that already needs to be done
for dynamic hugepage allocations which is almost exactly the same
situation. And everybody can use this as well (I think most of the code
is written already, but not merged).

> our approach is to teach the kernel some more tricks so that each
> solution need not be tweaked
> 
> these are at obvious odds as they tackle the problem by going in
> pretty much opposite directions ... yours leads to a tighter system in
> the end, but ours leads to much more rapid development and deployment

OK that's fair enough, but considering that it doesn't actually fix
the problem properly; and that it does weird and wonderful things with
our already fragile page reclaim path, then it is not a good idea to
merge it upstream.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

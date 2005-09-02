Message-ID: <4318C79D.1050000@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:43:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F136.4040601@yahoo.com.au>	<1125666486.30867.11.camel@localhost.localdomain>	<p73k6hzqk1w.fsf@verdi.suse.de> <20050902.141255.50099210.davem@davemloft.net>
In-Reply-To: <20050902.141255.50099210.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Bear with me Dave, I'll repeat myself a bit, for the benefit of lkml.


Andi Kleen wrote:
>>>Yeah quite a few. I suspect most MIPS also would have a problem in this
>>>area.
>>
>>cmpxchg can be done with LL/SC can't it? Any MIPS should have that.
> 
> 
> Right.
> 
> On PARISC, I don't see where they are emulating compare and swap
> as indicated.  They are doing the funny hashed spinlocks for the
> atomic_t operations and bitops, but that is entirely different.
> 

Yep, same as SPARC (at least, SPARC's 32-bit atomic_t).

> cmpxchg() has to operate in an environment where, unlike the atomic_t
> and bitops, you cannot control the accessors to the object at all.
> 
> The DRM is the only place in the kernel that requires cmpxchg()
> and you can thus make a list of what platform can provide cmpxchg()
> by which ones support DRM and thus provide the cmpxchg() macro already
> in asm/system.h
> 
> We really can't require support for this primitive kernel wide, it's
> simply not possible on a couple chips.

Not a generic cmpxchg, no. However, I _believe_ that those
architectures that are missing something like ll/sc or real
atomic cmpxchg should still be able to implement an
"atomic_cmpxchg" on their atomic type.

Sorry if I wasn't at all clear initially. What I'd be interested
in is an architecture that doesn't support ll/sc or real cmpxchg
*and* does not implement atomic_t operations with locks.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

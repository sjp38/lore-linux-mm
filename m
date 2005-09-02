Message-ID: <4318C28A.5010000@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:22:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>	<4317F136.4040601@yahoo.com.au>	<1125666486.30867.11.camel@localhost.localdomain> <p73k6hzqk1w.fsf@verdi.suse.de>
In-Reply-To: <p73k6hzqk1w.fsf@verdi.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
> 
> 
>>On Gwe, 2005-09-02 at 16:29 +1000, Nick Piggin wrote:
>>
>>>2/7
>>>Implement atomic_cmpxchg for i386 and ppc64. Is there any
>>>architecture that won't be able to implement such an operation?
>>
>>i386, sun4c, ....
> 
> 
> Actually we have cmpxchg on i386 these days - we don't support
> any SMP i386s so it's just done non atomically.
>  

Yes, I guess that's what Alan must have meant.

This atomic_cmpxchg, unlike a "regular" cmpxchg, has the advantage
that the memory altered should always be going through the atomic_
accessors, and thus should be implementable with spinlocks.

See for example, arch/sparc/lib/atomic32.c

At least, that's what I'm hoping for.

> 
>>Yeah quite a few. I suspect most MIPS also would have a problem in this
>>area.
> 
> 
> cmpxchg can be done with LL/SC can't it? Any MIPS should have that.
> 

Yes, and indeed it does. However it also tests for "cpu_has_llsc",
but I suspect that SMP isn't supported on those CPUs without ll/sc,
and thus an atomic_cmpxchg could be emulated by disabling interrupts.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

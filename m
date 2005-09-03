Message-ID: <4318FF2B.6000805@yahoo.com.au>
Date: Sat, 03 Sep 2005 11:40:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>	 <4317F136.4040601@yahoo.com.au>	 <1125666486.30867.11.camel@localhost.localdomain>	 <p73k6hzqk1w.fsf@verdi.suse.de>  <4318C28A.5010000@yahoo.com.au> <1125705471.30867.40.camel@localhost.localdomain>
In-Reply-To: <1125705471.30867.40.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:

>>but I suspect that SMP isn't supported on those CPUs without ll/sc,
>>and thus an atomic_cmpxchg could be emulated by disabling interrupts.
> 
> 
> It's obviously emulatable on any platform - the question is at what
> cost. For x86 it probably isn't a big problem as there are very very few
> people who need to build for 386 any more and there is already a big
> penalty for such chips.
> 
> 

Thanks Alan, Dave, others.

We'll see how things go. I'm fairly sure that for my usage it will
be a win even if it is costly. It is replacing an atomic_inc_return,
and a read_lock/read_unlock pair.

But if it does one day get merged, and proves to be very costly on
some architectures then we'll need to be careful about where it gets
used.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

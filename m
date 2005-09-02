Message-ID: <4318C884.3050607@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:47:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <1125666486.30867.11.camel@localhost.localdomain>	<p73k6hzqk1w.fsf@verdi.suse.de>	<4318C28A.5010000@yahoo.com.au> <20050902.143149.08652495.davem@davemloft.net>
In-Reply-To: <20050902.143149.08652495.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: ak@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Sat, 03 Sep 2005 07:22:18 +1000
> 
> 
>>This atomic_cmpxchg, unlike a "regular" cmpxchg, has the advantage
>>that the memory altered should always be going through the atomic_
>>accessors, and thus should be implementable with spinlocks.
>>
>>See for example, arch/sparc/lib/atomic32.c
>>
>>At least, that's what I'm hoping for.
> 
> 
> Ok, as long as the rule is that all accesses have to go
> through accessor macros, it would work.  This is not true
> for existing uses of cmpxchg() btw, userland accesses shared
> locks with the kernel would using any kind of accessors we
> can control.
> 
> This means that your atomic_cmpxchg() cannot be used for locking
> objects shared with userland, as DRM wants, since the hashed spinlock
> trick does not work in such a case.
> 

So neither could currently supported atomic_t ops be shared with
userland accesses?

Then I think it would not be breaking any interface rule to do an
atomic_t atomic_cmpxchg either. Definitely for my usage it will
not be shared with userland.

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

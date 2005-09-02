Date: Fri, 02 Sep 2005 14:12:55 -0700 (PDT)
Message-Id: <20050902.141255.50099210.davem@davemloft.net>
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <p73k6hzqk1w.fsf@verdi.suse.de>
References: <4317F136.4040601@yahoo.com.au>
	<1125666486.30867.11.camel@localhost.localdomain>
	<p73k6hzqk1w.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andi Kleen <ak@suse.de>
Date: 02 Sep 2005 22:41:31 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> > Yeah quite a few. I suspect most MIPS also would have a problem in this
> > area.
> 
> cmpxchg can be done with LL/SC can't it? Any MIPS should have that.

Right.

On PARISC, I don't see where they are emulating compare and swap
as indicated.  They are doing the funny hashed spinlocks for the
atomic_t operations and bitops, but that is entirely different.

cmpxchg() has to operate in an environment where, unlike the atomic_t
and bitops, you cannot control the accessors to the object at all.

The DRM is the only place in the kernel that requires cmpxchg()
and you can thus make a list of what platform can provide cmpxchg()
by which ones support DRM and thus provide the cmpxchg() macro already
in asm/system.h

We really can't require support for this primitive kernel wide, it's
simply not possible on a couple chips.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

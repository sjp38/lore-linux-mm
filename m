Date: Fri, 02 Sep 2005 14:31:49 -0700 (PDT)
Message-Id: <20050902.143149.08652495.davem@davemloft.net>
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <4318C28A.5010000@yahoo.com.au>
References: <1125666486.30867.11.camel@localhost.localdomain>
	<p73k6hzqk1w.fsf@verdi.suse.de>
	<4318C28A.5010000@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:22:18 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: ak@suse.de, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> This atomic_cmpxchg, unlike a "regular" cmpxchg, has the advantage
> that the memory altered should always be going through the atomic_
> accessors, and thus should be implementable with spinlocks.
> 
> See for example, arch/sparc/lib/atomic32.c
> 
> At least, that's what I'm hoping for.

Ok, as long as the rule is that all accesses have to go
through accessor macros, it would work.  This is not true
for existing uses of cmpxchg() btw, userland accesses shared
locks with the kernel would using any kind of accessors we
can control.

This means that your atomic_cmpxchg() cannot be used for locking
objects shared with userland, as DRM wants, since the hashed spinlock
trick does not work in such a case.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 88A4C6B00B2
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:52:27 -0500 (EST)
Date: Mon, 23 Feb 2009 14:51:05 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <200902240101.26362.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0902231429360.28573@blonde.anvils>
References: <499BE7F8.80901@csr.com> <499DB6EC.3020904@cs.helsinki.fi>
 <Pine.LNX.4.64.0902192022210.8254@blonde.anvils> <200902240101.26362.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Nick Piggin wrote:
> 
> Well, the buffer is only non-modified in the case of one of the
> allocators (SLAB). All others overwrite some of the data region
> with their own metadata.
> 
> I think it is OK to use const, though. Because k(z)free has the
> knowledge that the data will not be touched by the caller any
> longer.

Sorry, you're not adding anything new to the thread here.

Yes, the caller is surrendering the buffer, so we can get
away with calling the argument const; and Linus argues that's
helpful in the case of kfree (to allow passing a const pointer
without having to cast it).

My contention is that kzfree(const void *ptr) is nonsensical
because it says please zero this buffer without modifying it.

But the change has gone in, I seem to be the only one still
bothered by it, and I've conceded that the "z" might stand
for zap rather than zero.

So it may be saying please hide the contents of this buffer,
rather than please zero it.  And then it can be argued that
the modification is an implementation detail which happens
(like other housekeeping internal to the sl?b allocator)
only after the original buffer has been freed.

Philosophy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

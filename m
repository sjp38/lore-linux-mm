Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3BC6B004D
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 22:10:16 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090620002817.GA2524@elf.ucw.cz>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090619145913.GA1389@ucw.cz> <1245450449.16880.10.camel@pasglop>
	 <20090619232336.GA2442@elf.ucw.cz> <1245455409.16880.15.camel@pasglop>
	 <20090620002817.GA2524@elf.ucw.cz>
Content-Type: text/plain
Date: Sat, 20 Jun 2009 12:10:09 +1000
Message-Id: <1245463809.16880.18.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, 2009-06-20 at 02:28 +0200, Pavel Machek wrote:
> 
> Academic for boot, probably real for suspend/resume. There the atomic
> reserves could matter because the memory can be pretty full when you
> start suspend.

Right, that might be something to look into, though we haven't yet
applied the technique for suspend & resume. My main issue with it at the
moment is how do I synchronize with allocations that are already
sleeping when changing the gfp flag mask without bloating the normal
path. I haven't had time to look into it, it's mostly a problem local to
the page allocator and reclaim, not much to do with SL*Bs though, which
is fortunate.

I also suspect that we might want to try to make -some- amount of free
space before starting suspend, though of course not nearly as
aggressively as with std.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 5 May 2008 08:23:34 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc][patch 0/3] bootmem2: a memory block-oriented boot time
 allocator
In-Reply-To: <20080505095938.326928514@symbol.fehenstaub.lan>
Message-ID: <alpine.LFD.1.10.0805050820000.32269@woody.linux-foundation.org>
References: <20080505095938.326928514@symbol.fehenstaub.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


On Mon, 5 May 2008, Johannes Weiner wrote:
> 
> here is a bootmem allocator replacement that uses one bitmap for all
> available pages and works with a model of contiguous memory blocks
> that reside on nodes instead of nodes only as the current allocator
> does.

Won't this have problems with huge non-contiguous areas?

Some setups have traditionally had node memory separated in physical space 
by the high bits of the memory address, and using a single bitmap for such 
things would potentially be basically impossible - even with a single bit 
per page, the "span" of possible pages is potentially just too high, even 
if the nodes themselves don't have tons of memory, because the memory is 
just very spread out - and allocating the initial bitmap may not work 
reliably.

Now, admittedly I don't know if we even support that kind of thing or if 
people really do things that way any more, so maybe it's not an issue.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

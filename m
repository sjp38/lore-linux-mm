From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [rfc][patch 0/3] bootmem2: a memory block-oriented boot time allocator
References: <20080505095938.326928514@symbol.fehenstaub.lan>
Date: Mon, 05 May 2008 13:23:30 +0200
In-Reply-To: <20080505095938.326928514@symbol.fehenstaub.lan> (Johannes
	Weiner's message of "Mon, 05 May 2008 11:59:38 +0200")
Message-ID: <87ve1touz1.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

Johannes Weiner <hannes@saeurebad.de> writes:

> The problem is that memory nodes are not anymore garuanteed to be
> linear on certain configurations, they may overlap each other and a
> node might span page ranges that are not physically residing on it.
>
> Note that this is in no way theoretical only, bootmem suffers from
> this fact right now: A pfn range has to be operated on on every node
> that holds it (because a PFN is not unique anymore) and bootmem can
> not garuantee that the memory allocated from a specific node actually
> resides on that node.
>
> For example:
>
> 	node 0: 0-2G, 4-6G
> 	node 1: 2-4G, 6-8G
>
> Bootmem currently sees the 2-4G range twice (and has to operate on
> both node's bitmaps) and if memory is allocated on node 1, it may
> return memory that is between the 2-4G range and actually resides on
> node 0.

Uh, mixup.  The memory resides on node 1 but may get allocated from
node 0.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

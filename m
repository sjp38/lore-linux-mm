From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [rfc][patch 0/3] bootmem2: a memory block-oriented boot time allocator
References: <20080505095938.326928514@symbol.fehenstaub.lan>
	<481F58DD.9000600@firstfloor.org>
Date: Tue, 06 May 2008 10:57:12 +0200
In-Reply-To: <481F58DD.9000600@firstfloor.org> (Andi Kleen's message of "Mon,
	05 May 2008 20:58:37 +0200")
Message-ID: <87r6cflsif.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

Andi Kleen <andi@firstfloor.org> writes:

>> (because a PFN is not unique anymore)
>
> That doesn't make sense. If a PFN is not uniquely mapping to a single
> memory page anymore the VM and lots of other code in the kernel will
> just not work. And each memory page can be only in a single node.

I meant it is not unique to the bootmem allocator because two bitmaps
might partially represent the same page range.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [PATCH 0/3] bootmem2 III
References: <20080509151713.939253437@saeurebad.de>
	<20080509184044.GA19109@one.firstfloor.org>
	<87lk2gtzta.fsf@saeurebad.de> <48275493.40601@firstfloor.org>
	<874p92qsvn.fsf@saeurebad.de> <482990AB.7070905@firstfloor.org>
Date: Wed, 14 May 2008 21:12:47 +0200
In-Reply-To: <482990AB.7070905@firstfloor.org> (Andi Kleen's message of "Tue,
	13 May 2008 14:59:23 +0200")
Message-ID: <87ve1gpumo.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Andi,

Andi Kleen <andi@firstfloor.org> writes:

>> I was wondering yesterday if it would be feasible to enforce
>> contiguousness for nodes.
>
> And lose the memory? That would make people not happy.

No, one node descriptor per contiguous block on the physical node.

So this setup:

node 0: 0-2G, 4-6G
node 1: 2-4G, 6-8G

would have 4 pgdats.

>> So that arch-code does not create one pgdat
>> for each node but one for each contiguous block.  I have not yet looked
>> deeper into it, but I suspect that other mm code has similar problems
>> with nodes spanning other nodes.
>
> I wouldn't think so. At least sparse memory with large holes is not that
> uncommon in the non x86 world.

I do not quite understand.  Holes are not the problem - the overlapping
is.

The current bootmem allocator for example might pass the same pfn twice
to the buddy allocator when two nodes overlap.  And I don't know if
other mm code has the same problem.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

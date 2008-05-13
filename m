Message-ID: <482990AB.7070905@firstfloor.org>
Date: Tue, 13 May 2008 14:59:23 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] bootmem2 III
References: <20080509151713.939253437@saeurebad.de>	<20080509184044.GA19109@one.firstfloor.org>	<87lk2gtzta.fsf@saeurebad.de> <48275493.40601@firstfloor.org> <874p92qsvn.fsf@saeurebad.de>
In-Reply-To: <874p92qsvn.fsf@saeurebad.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I was wondering yesterday if it would be feasible to enforce
> contiguousness for nodes.

And lose the memory? That would make people not happy.

  So that arch-code does not create one pgdat
> for each node but one for each contiguous block.  I have not yet looked
> deeper into it, but I suspect that other mm code has similar problems
> with nodes spanning other nodes.

I wouldn't think so. At least sparse memory with large holes is not that
uncommon in the non x86 world.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

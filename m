Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C89056B0096
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 15:14:45 -0500 (EST)
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.0912171356020.4640@router.home>
References: <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
	 <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>
	 <1261039534.27920.67.camel@laptop> <20091217085430.GG9804@basil.fritz.box>
	 <20091217144551.GA6819@linux.vnet.ibm.com>
	 <20091217175338.GL9804@basil.fritz.box>
	 <20091217190804.GB6788@linux.vnet.ibm.com>
	 <20091217195530.GM9804@basil.fritz.box>
	 <alpine.DEB.2.00.0912171356020.4640@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 21:14:15 +0100
Message-ID: <1261080855.27920.807.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 13:56 -0600, Christoph Lameter wrote:
> On Thu, 17 Dec 2009, Andi Kleen wrote:
> 
> > mmap_sem is a nasty lock, handlings lots of different things.
> 
> That is why I think that the accessors are a good first step.

They're not, they're daft, they operate on a global resource mm_struct,
that's the whole problem, giving it a different name isn't going to
solve anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

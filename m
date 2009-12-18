Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 785DC6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 00:18:07 -0500 (EST)
Date: Fri, 18 Dec 2009 06:17:54 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091218051754.GC417@elte.hu>
References: <20091217084046.GA9804@basil.fritz.box>
 <1261039534.27920.67.camel@laptop>
 <20091217085430.GG9804@basil.fritz.box>
 <20091217144551.GA6819@linux.vnet.ibm.com>
 <20091217175338.GL9804@basil.fritz.box>
 <20091217190804.GB6788@linux.vnet.ibm.com>
 <20091217195530.GM9804@basil.fritz.box>
 <alpine.DEB.2.00.0912171356020.4640@router.home>
 <1261080855.27920.807.camel@laptop>
 <alpine.DEB.2.00.0912171439380.4640@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912171439380.4640@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 17 Dec 2009, Peter Zijlstra wrote:
> 
> > > That is why I think that the accessors are a good first step.
> >
> > They're not, they're daft, they operate on a global resource mm_struct, 
> > that's the whole problem, giving it a different name isn't going to solve 
> > anything.
> 
> It is not about naming. The accessors hide the locking mechanism for 
> mmap_sem. Then you can change the locking in a central place.
> 
> The locking may even become configurable later. Maybe an embedded solution 
> will want the existing scheme but dual quad socket may want a distributed 
> reference counter to avoid bouncing cachelines on faults.

Hiding the locking is pretty much the worst design decision one can make.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

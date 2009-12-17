Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A87566B0085
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:55:34 -0500 (EST)
Date: Thu, 17 Dec 2009 20:55:30 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091217195530.GM9804@basil.fritz.box>
References: <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com> <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box> <1261039534.27920.67.camel@laptop> <20091217085430.GG9804@basil.fritz.box> <20091217144551.GA6819@linux.vnet.ibm.com> <20091217175338.GL9804@basil.fritz.box> <20091217190804.GB6788@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091217190804.GB6788@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 11:08:04AM -0800, Paul E. McKenney wrote:
> On Thu, Dec 17, 2009 at 06:53:39PM +0100, Andi Kleen wrote:
> > > OK, I have to ask...
> > > 
> > > Why not just use the already-existing SRCU in this case?
> > 
> > You right, SRCU could work. 
> > 
> > Still needs a lot more work of course.
> 
> As discussed with Peter on IRC, I have been idly thinking about how I
> would implement SRCU if I were starting on it today.  If you would like
> to see some specific improvements to SRCU, telling me about them would
> greatly increase the probability of my doing something about them.  ;-)

I think actual RCU improvements are pretty low on the list for this
one, so far we're not even completely sure how it would all work
on the high level.

mmap_sem is a nasty lock, handlings lots of different things.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

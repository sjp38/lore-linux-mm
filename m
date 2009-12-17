Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 461DB6B0071
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 03:41:44 -0500 (EST)
Date: Thu, 17 Dec 2009 09:41:39 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091217084138.GB9804@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com> <20091216104951.GD15031@basil.fritz.box> <20091216201218.42ff7f05.kamezawa.hiroyu@jp.fujitsu.com> <20091216113158.GE15031@basil.fritz.box> <alpine.DEB.2.00.0912161025290.8572@router.home> <1261004515.21028.510.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261004515.21028.510.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 12:01:55AM +0100, Peter Zijlstra wrote:
> On Wed, 2009-12-16 at 10:27 -0600, Christoph Lameter wrote:
> > On Wed, 16 Dec 2009, Andi Kleen wrote:
> > 
> > > > Do you have alternative recommendation rather than wrapping all accesses by
> > > > special functions ?
> > >
> > > Work out what changes need to be done for ranged mmap locks and do them all
> > > in one pass.
> > 
> > Locking ranges is already possible through the split ptlock and
> > could be enhanced through placing locks in the vma structures.
> > 
> > That does nothing solve the basic locking issues of mmap_sem. We need
> > Kame-sans abstraction layer. A vma based lock or a ptlock still needs to
> > ensure that the mm struct does not vanish while the lock is held.
> 
> It should, you shouldn't be able to remove a mm while there's still
> vma's around, and you shouldn't be able to remove a vma when there's
> still pagetables around. And if you rcu-free all of them you're stable
> enough for lots of speculative behaviour.

Yes, the existing reference counts are probably sufficient for all that.

Still need list stability.

> As for per-vma locks, those are pretty much useless too, there's plenty
> applications doing lots of work on a few very large vmas.

True.
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

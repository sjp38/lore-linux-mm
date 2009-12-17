Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA7AA6B0047
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:33:40 -0500 (EST)
Date: Thu, 17 Dec 2009 13:33:01 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
In-Reply-To: <20091217084046.GA9804@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.0912171331300.3638@router.home>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
 <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009, Andi Kleen wrote:

> > There are a few interesting cases like stack extention and hugetlbfs,
> > but I think we could start by falling back to mmap_sem locked behaviour
> > if the speculative thing fails.
>
> You mean fall back to mmap_sem if anything sleeps? Maybe. Would need
> to check how many such points are really there.

You always need some reference on the mm_struct (mm_read_lock) if you are
going to sleep to ensure that mm_struct still exists after waking up (page
fault, page allocation). RCU and other spin locks are not helping there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

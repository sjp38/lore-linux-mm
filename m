Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A2266B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 11:28:04 -0500 (EST)
Date: Wed, 16 Dec 2009 10:27:39 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
In-Reply-To: <20091216113158.GE15031@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.0912161025290.8572@router.home>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
 <20091216104951.GD15031@basil.fritz.box> <20091216201218.42ff7f05.kamezawa.hiroyu@jp.fujitsu.com> <20091216113158.GE15031@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009, Andi Kleen wrote:

> > Do you have alternative recommendation rather than wrapping all accesses by
> > special functions ?
>
> Work out what changes need to be done for ranged mmap locks and do them all
> in one pass.

Locking ranges is already possible through the split ptlock and
could be enhanced through placing locks in the vma structures.

That does nothing solve the basic locking issues of mmap_sem. We need
Kame-sans abstraction layer. A vma based lock or a ptlock still needs to
ensure that the mm struct does not vanish while the lock is held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

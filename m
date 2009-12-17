Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E28426B0093
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 15:14:15 -0500 (EST)
Date: Thu, 17 Dec 2009 14:13:42 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
In-Reply-To: <1261080470.27920.798.camel@laptop>
Message-ID: <alpine.DEB.2.00.0912171412040.4640@router.home>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>  <20091216101107.GA15031@basil.fritz.box>  <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>  <20091216102806.GC15031@basil.fritz.box>  <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
  <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>  <alpine.DEB.2.00.0912171331300.3638@router.home> <1261080470.27920.798.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009, Peter Zijlstra wrote:

> > You always need some reference on the mm_struct (mm_read_lock) if you are
> > going to sleep to ensure that mm_struct still exists after waking up (page
> > fault, page allocation). RCU and other spin locks are not helping there.
>
> Depends what you go to sleep for, the page fault retry patches simply
> retook the whole fault and there is no way the mm could have gone away
> when userspace isn't executing.

get_user_pages ?

> Also pinning a page will pin the vma will pin the mm, and then you can
> always take explicit mm_struct refs, but you really want to avoid that
> since that's a global cacheline again.

Incrementing a refcount on some random page wont protect you unless
mmap_sem is held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

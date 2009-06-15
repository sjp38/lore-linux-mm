Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 22E1C6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 02:43:33 -0400 (EDT)
Date: Mon, 15 Jun 2009 08:44:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615064447.GA18390@wotan.suse.de>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615042753.GA20788@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 12:27:53PM +0800, Wu Fengguang wrote:
> On Mon, Jun 15, 2009 at 11:18:18AM +0800, Balbir Singh wrote:
> > Wu Fengguang wrote:
> > > Hi all,
> > > 
> > > Comments are warmly welcome on the newly introduced uevent code :)
> > > 
> > > I hope we can reach consensus in this round and then be able to post
> > > a final version for .31 inclusion.
> > 
> > Isn't that too aggressive? .31 is already in the merge window.
> 
> Yes, a bit aggressive. This is a new feature that involves complex logics.
> However it is basically a no-op when there are no memory errors,
> and when memory corruption does occur, it's better to (possibly) panic
> in this code than to panic unconditionally in the absence of this
> feature (as said by Rik).
> 
> So IMHO it's OK for .31 as long as we agree on the user interfaces,
> ie. /proc/sys/vm/memory_failure_early_kill and the hwpoison uevent.
> 
> It comes a long way through numerous reviews, and I believe all the
> important issues and concerns have been addressed. Nick, Rik, Hugh,
> Ingo, ... what are your opinions? Is the uevent good enough to meet
> your request to "die hard" or "die gracefully" or whatever on memory
> failure events?

Uevent? As in, send a message to userspace? I don't think this
would be ideal for a fail-stop/failover situation.

I can't see a good reason to rush to merge it.

IMO the userspace-visible changes have maybe not been considered
too thoroughly, which is what I'd be most worried about. I probably
missed seeing documentation of exact semantics and situations
where admins should tune things one way or the other.

Did we verify with filesystem maintainers (eg. btrfs) that the
!ISREG test will be enough to prevent oopses?

I hope it is going to be merged with an easy-to-use fault injector,
because that is the only way Joe kernel developer is ever going to
test it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

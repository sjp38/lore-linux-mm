Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D92CE6B0055
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 08:51:02 -0400 (EDT)
Date: Mon, 15 Jun 2009 13:51:43 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
In-Reply-To: <20090615042753.GA20788@localhost>
Message-ID: <Pine.LNX.4.64.0906151341160.25162@sister.anvils>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com>
 <20090615042753.GA20788@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009, Wu Fengguang wrote:
> On Mon, Jun 15, 2009 at 11:18:18AM +0800, Balbir Singh wrote:
> > Wu Fengguang wrote:
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
> Ingo, ... what are your opinions?

And for how long has this work been in linux-next or mmotm?

My opinion is that it's way too late for .31 - your only chance
is that Linus sometimes gets bored with playing safe, and decides
to break his rules and try something out regardless - but I'd hope
the bootmem business already sated his appetite for danger this time.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

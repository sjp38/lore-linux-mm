Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 594AC6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 14:22:28 -0400 (EDT)
Date: Wed, 11 Mar 2009 19:22:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311182216.GJ27823@random.random>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 10:33:00AM -0700, Linus Torvalds wrote:
> 
> On Wed, 11 Mar 2009, Ingo Molnar wrote:
> > 
> > FYI, in case you missed it. Large MM fix - and it's awfully late 
> > in -rc7.

I didn't specify it, but I didn't mean to submit it for immediate
inclusion. I posted it because it's ready and I wanted feedback from
Hugh/Nick/linux-mm so we can get this fixed when next merge window
open.

> Yeah, I'm not taking this at this point. No way, no-how.
> 
> If there is no simpler and obvious fix, it needs to go through -stable, 
> after having cooked in 2.6.30-rc for a while. Especially as this is a 
> totally uninteresting usage case that I can't see as being at all relevant 
> to any real world.

Actually AFIK there are mission critical real world applications that
used 512byte blocksize that were affected by this (I CC'ed relevant
people who knows). However this is rare thing so it almost never
triggers because the window is so small.

> Anybody who mixes O_DIRECT and fork() (and threads) is already doing some 
> seriously strange things. Nothing new there.

Most apps aren't affected of course. But almost all apps eventually
call fork (system/fork/exec/anything). Calling fork currently is
enough to generate memory corruption in the parent (i.e. lost O_DIRECT
reads from disk).

> And quite frankly, the patch is so ugly as-is that I'm not likely to take 
> it even into the 2.6.30 merge window unless it can be cleaned up. That 
> whole fork_pre_cow function is too f*cking ugly to live. We just don't 
> write code like this in the kernel.

Yes, this is exactly why I posted it now, to get feedback, it wasn't
meant for submission. Feel free to write it yourself in another way of
course, I included all relevant testcases to test alternate fixes too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

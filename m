Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C65576B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 13:35:39 -0400 (EDT)
Date: Wed, 11 Mar 2009 10:33:00 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090311170611.GA2079@elte.hu>
Message-ID: <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 11 Mar 2009, Ingo Molnar wrote:
> 
> FYI, in case you missed it. Large MM fix - and it's awfully late 
> in -rc7.

Yeah, I'm not taking this at this point. No way, no-how.

If there is no simpler and obvious fix, it needs to go through -stable, 
after having cooked in 2.6.30-rc for a while. Especially as this is a 
totally uninteresting usage case that I can't see as being at all relevant 
to any real world.

Anybody who mixes O_DIRECT and fork() (and threads) is already doing some 
seriously strange things. Nothing new there.

And quite frankly, the patch is so ugly as-is that I'm not likely to take 
it even into the 2.6.30 merge window unless it can be cleaned up. That 
whole fork_pre_cow function is too f*cking ugly to live. We just don't 
write code like this in the kernel.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 156AD6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 13:41:11 -0400 (EDT)
Date: Wed, 11 Mar 2009 18:41:03 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311174103.GA11979@elte.hu>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, 11 Mar 2009, Ingo Molnar wrote:
> > 
> > FYI, in case you missed it. Large MM fix - and it's awfully 
> > late in -rc7.
> 
> Yeah, I'm not taking this at this point. No way, no-how.
> 
> If there is no simpler and obvious fix, it needs to go through 
> -stable, after having cooked in 2.6.30-rc for a while. 
> Especially as this is a totally uninteresting usage case that 
> I can't see as being at all relevant to any real world.
> 
> Anybody who mixes O_DIRECT and fork() (and threads) is already 
> doing some seriously strange things. Nothing new there.

Hm, is there any security impact? Andrea is talking about data 
corruption. I'm wondering whether that's just corruption 
relative to whatever twisted semantics O_DIRECT has in this case 
[which would be harmless], or some true pagecache corruption 
going across COW (or other) protection domains that could be 
exploited [which would not be harmless].

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

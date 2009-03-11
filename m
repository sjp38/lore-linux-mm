Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C11BF6B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 15:07:13 -0400 (EDT)
Date: Wed, 11 Mar 2009 20:06:55 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090311190655.GA690@elte.hu>
References: <20090311170611.GA2079@elte.hu> <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain> <20090311182216.GJ27823@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311182216.GJ27823@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Mar 11, 2009 at 10:33:00AM -0700, Linus Torvalds wrote:
> > 
> > On Wed, 11 Mar 2009, Ingo Molnar wrote:
> > > 
> > > FYI, in case you missed it. Large MM fix - and it's awfully late 
> > > in -rc7.
> 
> I didn't specify it, but I didn't mean to submit it for 
> immediate inclusion. I posted it because it's ready and I 
> wanted feedback from Hugh/Nick/linux-mm so we can get this 
> fixed when next merge window open.

Good - i saw the '(fast-)gup fix' qualifier and fast-gup is a 
fresh feature. If the problem existed in earlier kernels too 
then i guess it isnt urgent.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD8D6B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:21:05 -0400 (EDT)
Date: Mon, 16 Mar 2009 11:14:59 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170502.57217.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903170419.38988.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain> <200903170502.57217.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> What part of that do you dislike, though? I don't think the lock is a
> particularly elegant idea either (shared cacheline, vmsplice, converting
> callers).

All of the absolute *crap* for no good reason.

Did you even look at your patch? It wasn't as ugly as Andrea's, but it was 
ugly enough, and it was buggy. That whole "decow" stuff was too f*cking 
ugly to live.

Couple that with the fact that no real-life user can possibly care, and 
that O_DIRECT is broken to begin with, and I say: "let's fix this with a 
_much_ smaller patch".

You may think that the lock isn't particularly "elegant", but I can only 
say "f*ck that, look at the number of lines of code, and the simplicity".

Your "elegant" argument is total and utter sh*t, in other words. The lock 
approach is tons more elegant, considering that it solves the problem much 
more cleanly, and with _much_ less crap.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

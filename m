Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C1BCA6B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 15:23:45 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:17:21 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170529.08995.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903161215150.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903170502.57217.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain> <200903170529.08995.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> What's buggy about it? Stupid bugs, or fundamentally broken?

The lack of locking.

> In my opinion it is not, given that you have to convert callers. If you
> say that you only care about fixing O_DIRECT, then yes I would probably
> agree the lock is nicer in that case.

F*ck me, I'm not going to bother to argue. I'm not going to merge your 
patch, it's that easy.

Quite frankly, I don't think that the "bug" is a bug to begin with. 
O_DIRECT+fork() can damn well continue to be broken. But if we fix it, we 
fix it the _clean_ way with a simple patch, not with that shit-for-logic 
horrible decow crap.

It's that simple. I refuse to take putrid industrial waste patches for 
something like this.

			Linus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

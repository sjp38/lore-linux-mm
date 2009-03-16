Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 784366B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 15:27:49 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:22:12 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170533.48423.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903161219340.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903170505.46905.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161115210.3675@localhost.localdomain> <200903170533.48423.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> > So is all the extra flags for no
> > good reason.
> 
> Which extra flags are you referring to?

Fuck me, didn't you even read your own patch?

What do you call PG_dontcow? 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

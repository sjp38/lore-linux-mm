Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BA6246B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:22:55 -0400 (EDT)
Date: Mon, 16 Mar 2009 11:17:02 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170505.46905.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903161115210.3675@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain> <200903170502.57217.nickpiggin@yahoo.com.au> <200903170505.46905.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Nick Piggin wrote:
> 
> If you disregard code motion and extra argument to copy_page_range,
> my fix is a couple of dozen lines change to existing code, plus the
> "decow" function (which could probably share a fair bit of code
> with do_wp_page).
> 
> Do you dislike the added complexity of the code? Or the behaviour
> that gets changed?

The complexity. That decow thing is shit. So is all the extra flags for no 
good reason. 

What's your argument against "keep it simple with a single lock, and 
adding basically a single line to reuse_swap_page() to say "don't reuse 
the page if the count is elevated"?

THAT is simple and elegant, and needs none of the complexity.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

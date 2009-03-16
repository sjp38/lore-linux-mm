Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5687A6B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:03:06 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 05:02:56 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170419.38988.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170502.57217.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 04:42:48 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > Well that in theory should close the race in one direction (writing into
> > the wrong page).
> >
> > I don't think it closes it in the other direction (reading the wrong data
> > from the page).
>
> Why?
>
> If somebody does a COW while we have a get_user_pages() page frame cached,
> the get_user_pages() will have increased the page count, so regardless of
> _who_ writes to the page, the writer will always get a new page. No?

[(no)]


> Maybe we could go back to also looking at page counts?

Hmm, possibly could.


> > BTW. have you looked at my approach yet? I've tried to solve the fork
> > vs gup race in yet another way. Don't know if you think it is palatable.
>
> I really think we should be able to fix this without _anything_ like that
> at all. Just the lock (and some reuse_swap_page() logic changes).

What part of that do you dislike, though? I don't think the lock is a
particularly elegant idea either (shared cacheline, vmsplice, converting
callers).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

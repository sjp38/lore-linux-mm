Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 79BCB6B005A
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:05:54 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 05:05:46 +1100
References: <1237007189.25062.91.camel@pasglop> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain> <200903170502.57217.nickpiggin@yahoo.com.au>
In-Reply-To: <200903170502.57217.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200903170505.46905.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 05:02:56 Nick Piggin wrote:
> On Tuesday 17 March 2009 04:42:48 Linus Torvalds wrote:
> > On Tue, 17 Mar 2009, Nick Piggin wrote:

> > > BTW. have you looked at my approach yet? I've tried to solve the fork
> > > vs gup race in yet another way. Don't know if you think it is
> > > palatable.
> >
> > I really think we should be able to fix this without _anything_ like that
> > at all. Just the lock (and some reuse_swap_page() logic changes).
>
> What part of that do you dislike, though?

If you disregard code motion and extra argument to copy_page_range,
my fix is a couple of dozen lines change to existing code, plus the
"decow" function (which could probably share a fair bit of code
with do_wp_page).

Do you dislike the added complexity of the code? Or the behaviour
that gets changed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

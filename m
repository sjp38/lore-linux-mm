Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B738C6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:33:56 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 05:33:47 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170505.46905.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161115210.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903161115210.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170533.48423.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 05:17:02 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > If you disregard code motion and extra argument to copy_page_range,
> > my fix is a couple of dozen lines change to existing code, plus the
> > "decow" function (which could probably share a fair bit of code
> > with do_wp_page).
> >
> > Do you dislike the added complexity of the code? Or the behaviour
> > that gets changed?
>
> The complexity. That decow thing is shit.

copying the page on fork instead of write protecting it? The code or
the idea? Code can certainly be improved...


> So is all the extra flags for no
> good reason.

Which extra flags are you referring to?


> What's your argument against "keep it simple with a single lock, and
> adding basically a single line to reuse_swap_page() to say "don't reuse
> the page if the count is elevated"?

I made them in a previous message. It depends on what callers you want
to convert I guess. I don't think vmsplice takes to the lock approach
very well though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

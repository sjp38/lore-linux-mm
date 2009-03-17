Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 109BA6B0055
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:42:37 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 16:42:24 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170529.08995.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161215150.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903161215150.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903171642.25760.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 06:17:21 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > What's buggy about it? Stupid bugs, or fundamentally broken?
>
> The lack of locking.

I don't think it's broken. I can't see a problem.


> > In my opinion it is not, given that you have to convert callers. If you
> > say that you only care about fixing O_DIRECT, then yes I would probably
> > agree the lock is nicer in that case.
>
> F*ck me, I'm not going to bother to argue. I'm not going to merge your
> patch, it's that easy.
>
> Quite frankly, I don't think that the "bug" is a bug to begin with.
> O_DIRECT+fork() can damn well continue to be broken. But if we fix it, we
> fix it the _clean_ way with a simple patch, not with that shit-for-logic
> horrible decow crap.
>
> It's that simple. I refuse to take putrid industrial waste patches for
> something like this.

I consider it is clean because it only adds branches in 3 places that
are not taken unless direct IO and fork are used, and it fixes the
"problem" in the VM directly leaving get_user_pages unchanged.

I don't think it is conceptually such a problem to copy pages rather
than COW them in fork. Seems fairly straightforward to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

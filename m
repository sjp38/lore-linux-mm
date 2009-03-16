Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A70A46B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:29:20 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 05:29:08 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170502.57217.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903170529.08995.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 05:14:59 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > What part of that do you dislike, though? I don't think the lock is a
> > particularly elegant idea either (shared cacheline, vmsplice, converting
> > callers).
>
> All of the absolute *crap* for no good reason.
>
> Did you even look at your patch? It wasn't as ugly as Andrea's, but it was
> ugly enough, and it was buggy. That whole "decow" stuff was too f*cking
> ugly to live.

What's buggy about it? Stupid bugs, or fundamentally broken?


> Couple that with the fact that no real-life user can possibly care, and
> that O_DIRECT is broken to begin with, and I say: "let's fix this with a
> _much_ smaller patch".

If it is based on nobody caring, I would prefer not to add anything at
all to "fix" it? We have MADV_DONTFORK already...


> You may think that the lock isn't particularly "elegant", but I can only
> say "f*ck that, look at the number of lines of code, and the simplicity".
>
> Your "elegant" argument is total and utter sh*t, in other words. The lock
> approach is tons more elegant, considering that it solves the problem much
> more cleanly, and with _much_ less crap.

In my opinion it is not, given that you have to convert callers. If you
say that you only care about fixing O_DIRECT, then yes I would probably
agree the lock is nicer in that case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

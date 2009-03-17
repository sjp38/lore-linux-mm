Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B6D776B0055
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:44:16 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Date: Tue, 17 Mar 2009 16:44:08 +1100
References: <1237007189.25062.91.camel@pasglop> <200903170533.48423.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161219340.3675@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903161219340.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903171644.09260.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 March 2009 06:22:12 Linus Torvalds wrote:
> On Tue, 17 Mar 2009, Nick Piggin wrote:
> > > So is all the extra flags for no
> > > good reason.
> >
> > Which extra flags are you referring to?
>
> Fuck me, didn't you even read your own patch?
>
> What do you call PG_dontcow?

It is a flag, there for a good reason.

It sounded like you were seeing more than one flag, and that
you thought they were useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

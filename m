Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6C94E6B003D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 11:21:34 -0400 (EDT)
Date: Mon, 23 Mar 2009 17:29:54 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090323162954.GB4192@elte.hu>
References: <20090318105735.BD17.A69D9226@jp.fujitsu.com> <20090322205249.6801.A69D9226@jp.fujitsu.com> <20090323091056.69DF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090323091056.69DF.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > following patch is my v2 approach.
> > it survive Andrea's three dio test-case.
> >
> > [...]

> Frankly, linus sugessted to insert one branch into do_wp_page(), 
> but I remove one branch from gup_fast.
> 
> I think it's good performance trade-off. but if anybody hate my 
> approach, I'll drop my chicken heart and try to linus suggested 
> way.

We started out with a difficult corner case problem (for an arguably 
botched syscall promise we made to user-space many moons ago), and 
an invasive and unmaintainable looking patch:

    8 files changed, 342 insertions(+), 77 deletions(-)

And your v2 is now:

    9 files changed, 66 insertions(+), 21 deletions(-)

... and it is also speeding up fast-gup. Which is a marked 
improvement IMO.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

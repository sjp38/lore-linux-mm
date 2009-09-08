Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 33A566B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 12:42:08 -0400 (EDT)
Date: Tue, 8 Sep 2009 17:40:50 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
In-Reply-To: <20090908153441.GB29902@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0909081735230.18233@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072238320.15430@sister.anvils> <20090908073119.GA29902@wotan.suse.de>
 <Pine.LNX.4.64.0909081258160.25652@sister.anvils> <20090908153441.GB29902@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Nick Piggin wrote:
> On Tue, Sep 08, 2009 at 01:17:01PM +0100, Hugh Dickins wrote:
> > By the way, in compiling that list of "special" architectures,
> > I was surprised not to find ia64 amongst them.  Not that it
> > matters to me, but I thought the Fujitsu guys were usually
> > keen on Itanium - do they realize that the special test is
> > excluding it, or do they have their own special patch for it?
> 
> I don't understand your question. Are you asking whether they
> know your patch will not enable zero pages on ia64?

That's what I was meaning to ask, yes; but wondering whether
perhaps they've already got their own patch to enable pte_special
on ia64, and just haven't got around to sending it in yet.

> 
> I guess pte special was primarily driven by gup_fast, which in
> turn was driven primarily by DB2 9.5, which I think might be
> only available on x86 and ibm's architectures.
> 
> But I admit to being a curious as to when I'll see a gup_fast
> patch come out of SGI or HP or Fujitsu :)

Yes, me too!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

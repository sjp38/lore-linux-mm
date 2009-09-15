Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 527776B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:15:52 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:15:07 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
In-Reply-To: <20090909104423.4bd23a2c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0909152111330.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072238320.15430@sister.anvils>
 <20090908113734.869cdad7.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0909081231480.25652@sister.anvils>
 <20090909104423.4bd23a2c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Sep 2009, KAMEZAWA Hiroyuki wrote:
> On Tue, 8 Sep 2009 12:56:57 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > Though I like that we don't _need_ to change mlock.c for reinstated
> > ZERO_PAGE, this morning I'm having trouble persuading myself that
> > mlocking a readonly anonymous area is too silly to optimize for.
> > 
> > Maybe the very people who persuaded you to bring back the anonymous
> > use of ZERO_PAGE, are also doing a huge mlock of the area first?
> No, as far as I know, they'll not do huge mlock.

Thanks for that (not entirely conclusive!) info.

I've decided for the moment to make a couple of further optimizations
in mlock.c (along with the comment you asked for), and leave adding
another __get_user_pages flag until a case for it is demonstrated.

Small patch series following shortly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

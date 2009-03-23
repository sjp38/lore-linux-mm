Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1E306B004D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:22:16 -0400 (EDT)
Date: Mon, 23 Mar 2009 01:14:18 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: decouple unevictable lru from mmu
Message-ID: <20090323001418.GA32758@cmpxchg.org>
References: <20090321102044.GA3427@cmpxchg.org> <1237752784-1989-1-git-send-email-hannes@cmpxchg.org> <20090323084423.490C.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090323084423.490C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 23, 2009 at 08:46:06AM +0900, KOSAKI Motohiro wrote:
> > @@ -206,7 +206,6 @@ config VIRT_TO_BUS
> >  config UNEVICTABLE_LRU
> >  	bool "Add LRU list to track non-evictable pages"
> >  	default y
> > -	depends on MMU
> >  	help
> >  	  Keeps unevictable pages off of the active and inactive pageout
> >  	  lists, so kswapd will not waste CPU time or have its balancing
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 478223b..ceaa629 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> 
> David alread made this portion and it already merged in mmotm.
> Don't you work on mmotm?

Ah, stupid me.  I was even on the Cc for David's patches.  I missed
them, sorry.

David, why do we need two Kconfig symbols for mlock and the mlock page
bit?  Don't we always provide mlock on mmu and never on nommu?
Anyway, that is just out of curiousity.  Good that the change is
already done, so please ignore this patch.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

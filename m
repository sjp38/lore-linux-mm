Date: Thu, 03 Jul 2008 15:02:23 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 1/10] fix UNEVICTABLE_LRU and !PROC_PAGE_MONITOR build
In-Reply-To: <20080702223652.3b57dc4b.akpm@linux-foundation.org>
References: <20080625185950.D84F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080702223652.3b57dc4b.akpm@linux-foundation.org>
Message-Id: <20080703145454.B963.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Benjamin Kidwell <benjkidwell@yahoo.com>
List-ID: <linux-mm.kvack.org>

> >  config UNEVICTABLE_LRU
> >  	bool "Add LRU list to track non-evictable pages"
> >  	default y
> > +	select PAGE_WALKER
> 
> So what do we do?  Make UNEVICTABLE_LRU depend on CONFIG_MMU?  That
> would be even worse than what we have now.

I'm not sure about what do we do. but I'd prefer "depends on MMU".
because current munlock implementation need pagewalker.
So, munlock rewriting have high risk rather than change depend on.

Rik, What do you think?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

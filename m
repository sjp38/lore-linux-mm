Date: Thu, 3 Jul 2008 09:16:37 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [-mm][PATCH 1/10] fix UNEVICTABLE_LRU and !PROC_PAGE_MONITOR
 build
Message-ID: <20080703091637.5fcb0308@bree.surriel.com>
In-Reply-To: <20080703145454.B963.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185950.D84F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080702223652.3b57dc4b.akpm@linux-foundation.org>
	<20080703145454.B963.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Benjamin Kidwell <benjkidwell@yahoo.com>
List-ID: <linux-mm.kvack.org>

On Thu, 03 Jul 2008 15:02:23 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > >  config UNEVICTABLE_LRU
> > >  	bool "Add LRU list to track non-evictable pages"
> > >  	default y
> > > +	select PAGE_WALKER
> > 
> > So what do we do?  Make UNEVICTABLE_LRU depend on CONFIG_MMU?  That
> > would be even worse than what we have now.
> 
> I'm not sure about what do we do. but I'd prefer "depends on MMU".
> because current munlock implementation need pagewalker.
> So, munlock rewriting have high risk rather than change depend on.
> 
> Rik, What do you think?

I suspect that systems without an MMU will not run into
page replacement scalability issues, so making the
UNEVICTABLE_LRU config option depend on MMU should be
ok.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

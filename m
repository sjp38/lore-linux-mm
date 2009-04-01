Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2CE26B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 12:05:24 -0400 (EDT)
Date: Wed, 1 Apr 2009 18:03:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename  sc.may_swap to may_unmap)
Message-ID: <20090401160342.GA1930@cmpxchg.org>
References: <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com> <20090401094955.GA1656@cmpxchg.org> <20090401185418.B204.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090401185418.B204.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 01, 2009 at 06:55:45PM +0900, KOSAKI Motohiro wrote:
> > > > How about making may_swap mean the following:
> > > > 
> > > > 	@@ -642,6 +639,8 @@ static unsigned long shrink_page_list(st
> > > > 	 		 * Try to allocate it some swap space here.
> > > > 	 		 */
> > > > 	 		if (PageAnon(page) && !PageSwapCache(page)) {
> > > > 	+			if (!sc->map_swap)
> > > > 	+				goto keep_locked;
> > > > 	 			if (!(sc->gfp_mask & __GFP_IO))
> > > > 	 				goto keep_locked;
> > > > 	 			if (!add_to_swap(page))
> > > > 
> > > > try_to_free_pages() always sets it.
> > > > 
> > > What is the advantage than _not_ scanning ANON LRU at all ?
> > 
> > I thought we could collect anon pages that don't need swap io.
> 
> Yes. but Is this important?
> if memcg reclaim don't collect sleal swapcache, other global reclaim can.
> 
> Am I missing any viewpoint?

Nothing I am aware of, it should work as you suggest.  I just wasn't
sure about the memory controller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

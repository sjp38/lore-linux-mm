Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1520A6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 05:54:58 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n319tlPa005860
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Apr 2009 18:55:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C67645DD75
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:55:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AC8745DD72
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:55:47 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E131DB8016
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:55:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C56811DB8013
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:55:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename  sc.may_swap to may_unmap)
In-Reply-To: <20090401094955.GA1656@cmpxchg.org>
References: <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com> <20090401094955.GA1656@cmpxchg.org>
Message-Id: <20090401185418.B204.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Apr 2009 18:55:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

> > > How about making may_swap mean the following:
> > > 
> > > 	@@ -642,6 +639,8 @@ static unsigned long shrink_page_list(st
> > > 	 		 * Try to allocate it some swap space here.
> > > 	 		 */
> > > 	 		if (PageAnon(page) && !PageSwapCache(page)) {
> > > 	+			if (!sc->map_swap)
> > > 	+				goto keep_locked;
> > > 	 			if (!(sc->gfp_mask & __GFP_IO))
> > > 	 				goto keep_locked;
> > > 	 			if (!add_to_swap(page))
> > > 
> > > try_to_free_pages() always sets it.
> > > 
> > What is the advantage than _not_ scanning ANON LRU at all ?
> 
> I thought we could collect anon pages that don't need swap io.

Yes. but Is this important?
if memcg reclaim don't collect sleal swapcache, other global reclaim can.

Am I missing any viewpoint?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 21A986B00C2
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:21:48 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N9NcPx030173
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Mar 2009 18:23:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A3E12AEA81
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:23:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C5AE1EF081
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:23:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 53795E08006
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:23:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 033AE1DB8043
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 18:23:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU  lists
In-Reply-To: <20090323175507.6A18.A69D9226@jp.fujitsu.com>
References: <20090323084254.GA1685@cmpxchg.org> <20090323175507.6A18.A69D9226@jp.fujitsu.com>
Message-Id: <20090323182039.6A1B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Mar 2009 18:23:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> > > this is the just reason why current code don't call add_page_to_unevictable_list().
> > > add_page_to_unevictable_list() don't use pagevec. it is needed for avoiding race.
> > > 
> > > then, if readahead path (i.e. add_to_page_cache_lru()) use add_page_to_unevictable_list(),
> > > it can cause zone->lru_lock contention storm.
> > 
> > How is it different then shrink_page_list()?  If readahead put a
> > contiguous chunk of unevictable pages to the file lru, then
> > shrink_page_list() will as well call add_page_to_unevictable_list() in
> > a loop.
> 
> it's probability issue.
> 
> readahead: we need to concern
> 	(1) readahead vs readahead
> 	(2) readahead vs reclaim
> 
> vmscan: we need to concern
> 	(3) background reclaim vs foreground reclaim
> 
> So, (3) is rarely event than (1) and (2).
> Am I missing anything?

my last mail explanation is too poor. sorry.
I don't dislike this patch concept. but it seems a bit naive against contention.
if we can decrease contention risk, I can ack with presure.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

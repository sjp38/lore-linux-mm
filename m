Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC7E900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 09:13:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4F3723EE0B5
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:13:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3339645DE68
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:13:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 171F545DE4E
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:13:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 09F4AE08003
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:13:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C54FA1DB8038
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:13:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 4/8] Make clear description of putback_lru_page
In-Reply-To: <20110428084500.GG12437@cmpxchg.org>
References: <BANLkTik2FTKgSSYkyP4XT4pkhOYvpjgSTA@mail.gmail.com> <20110428084500.GG12437@cmpxchg.org>
Message-Id: <20110501221459.75E4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  1 May 2011 22:13:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

> On Thu, Apr 28, 2011 at 08:20:32AM +0900, Minchan Kim wrote:
> > On Wed, Apr 27, 2011 at 5:11 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Wed, 27 Apr 2011 01:25:21 +0900
> > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > >
> > >> Commonly, putback_lru_page is used with isolated_lru_page.
> > >> The isolated_lru_page picks the page in middle of LRU and
> > >> putback_lru_page insert the lru in head of LRU.
> > >> It means it could make LRU churning so we have to be very careful.
> > >> Let's clear description of putback_lru_page.
> > >>
> > >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > >> Cc: Mel Gorman <mgorman@suse.de>
> > >> Cc: Rik van Riel <riel@redhat.com>
> > >> Cc: Andrea Arcangeli <aarcange@redhat.com>
> > >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > >
> > > seems good...
> > > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >
> > > But is there consensus which side of LRU is tail? head?
> > 
> > I don't know. I used to think it's head.
> > If other guys raise a concern as well, let's talk about it. :)
> > Thanks
> 
> I suppose we add new pages to the head of the LRU and reclaim old
> pages from the tail.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

So, It would be better if isolate_lru_page() also have "LRU tail blah blah blah"
comments.

anyway,
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

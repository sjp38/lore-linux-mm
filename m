Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE346B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 05:17:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 594A13EE0AE
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:17:25 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E41345DE5A
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:17:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 260CA45DE58
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:17:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 194281DB8048
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:17:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4D2E1DB8045
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:17:24 +0900 (JST)
Date: Thu, 28 Apr 2011 18:10:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
Message-Id: <20110428181046.b81635ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110428085432.GI12437@cmpxchg.org>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
	<20110427170304.d31c1398.kamezawa.hiroyu@jp.fujitsu.com>
	<20110428085432.GI12437@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 28 Apr 2011 10:54:32 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Apr 27, 2011 at 05:03:04PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 27 Apr 2011 01:25:20 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > In some __zone_reclaim case, we don't want to shrink mapped page.
> > > Nonetheless, we have isolated mapped page and re-add it into
> > > LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> > > 
> > > Of course, when we isolate the page, the page might be mapped but
> > > when we try to migrate the page, the page would be not mapped.
> > > So it could be migrated. But race is rare and although it happens,
> > > it's no big deal.
> > > 
> > > Cc: Christoph Lameter <cl@linux.com>
> > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > 
> > Hmm, it seems mm/memcontrol.c::mem_cgroup_isolate_pages() should be updated, too.
> 
> memcg reclaim always does sc->may_unmap = 1.  What is there to
> communicate to mem_cgroup_isolate_pages?
>

Hmm, maybe you're right and nothing to do until memcg need to support soft
limit in zone reclaim mode. I hope no more users.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

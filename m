Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B0D486B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:50:54 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1AAoqCN029761
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 19:50:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 083DE45DE52
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:50:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AF2F845DE55
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:50:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BD151DB8046
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:50:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EF3941DB804A
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:50:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
In-Reply-To: <20090210104222.GB1740@cmpxchg.org>
References: <20090210184055.6FCB.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210104222.GB1740@cmpxchg.org>
Message-Id: <20090210195002.6FE6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 19:50:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Feb 10, 2009 at 06:42:30PM +0900, KOSAKI Motohiro wrote:
> > 
> > KAMEZAWA Hiroyuki sugessted to remove zone->prev_priority.
> > it's because Split-LRU VM doesn't use this parameter at all.
> > 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |   27 -------------------------
> >  include/linux/mmzone.h     |   15 --------------
> >  mm/memcontrol.c            |   31 -----------------------------
> >  mm/page_alloc.c            |    2 -
> >  mm/vmscan.c                |   48 ++-------------------------------------------
> >  mm/vmstat.c                |    2 -
> >  6 files changed, 3 insertions(+), 122 deletions(-)
> 
> > Index: b/include/linux/memcontrol.h
> > ===================================================================
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -88,14 +88,7 @@ extern void mem_cgroup_end_migration(str
> >  /*
> >   * For memory reclaim.
> >   */
> > -extern int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem);
> 
> This bit crept in from the next patch, I think.

Grr.
I'll fix this soon.

Thanks for carefully reviewing! 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

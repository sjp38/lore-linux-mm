Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A12B6B0087
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 20:43:14 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J0hAea004690
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 09:43:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D7AB45DE52
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:43:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B5D945DE4F
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:43:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22AB2E38002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:43:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D4DDDE08001
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 09:43:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <alpine.DEB.2.00.1010181050000.1294@router.home>
References: <20101013160640.ADC9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010181050000.1294@router.home>
Message-Id: <20101019094109.A1AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 09:43:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 13 Oct 2010, KOSAKI Motohiro wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 194bdaa..8b50e52 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1093,6 +1093,7 @@ static void drain_pages(unsigned int cpu)
> >  		pcp = &pset->pcp;
> >  		free_pcppages_bulk(zone, pcp->count, pcp);
> >  		pcp->count = 0;
> > +		__flush_zone_state(zone, NR_FREE_PAGES);
> >  		local_irq_restore(flags);
> >  	}
> >  }
> 
> drain_zone_pages() is called from refresh_vm_stats() and
> refresh_vm_stats() already flushes the counters. The patch will not change
> anything.

Well, it's drain_pages(), not drain_zone_pages(). drain_pages() is 
called from reclaim path.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

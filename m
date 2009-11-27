Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5B8DE6B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 00:48:04 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAR5m1Gd026356
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 27 Nov 2009 14:48:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A0E445DE61
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:48:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0FCF45DE55
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:48:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA561DB803E
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:48:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF7698F800B
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:47:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] vmscan: make lru_index() helper function
In-Reply-To: <alpine.DEB.2.00.0911262138310.14657@kernalhack.brc.ubc.ca>
References: <20091127091755.A7CF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911262138310.14657@kernalhack.brc.ubc.ca>
Message-Id: <20091127144636.A7E4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 27 Nov 2009 14:47:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > @@ -1373,10 +1378,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> >  	 */
> >  	reclaim_stat->recent_rotated[file] += nr_rotated;
> >  
> > -	move_active_pages_to_lru(zone, &l_active,
> > -						LRU_ACTIVE + file * LRU_FILE);
> > -	move_active_pages_to_lru(zone, &l_inactive,
> > -						LRU_BASE   + file * LRU_FILE);
> > +	move_active_pages_to_lru(zone, &l_active, lru_index(1, file));
> > +	move_active_pages_to_lru(zone, &l_inactive, lru_index(0, file));
> 
> How about:
> 	move_active_pages_to_lru(zone, &l_active, lru_index(LRU_ACTIVE, file));
> 	move_active_pages_to_lru(zone, &l_inactive, lru_index(LRU_BASE, file));
> ?

No. lru_index mean convert two boolean to one index. it shoudn't be passed
lru index itself.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

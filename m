Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3FDAF6B010B
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 19:33:49 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o060XkkW018156
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 6 Jan 2010 09:33:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4418B45DE4F
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:33:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 19C7E45DE56
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:33:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EB8931DB8043
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:33:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A4143E18001
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 09:33:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
In-Reply-To: <20100105101821.GA28975@csn.ul.ie>
References: <20100105105328.96CE.A69D9226@jp.fujitsu.com> <20100105101821.GA28975@csn.ul.ie>
Message-Id: <20100106093257.9E2B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  6 Jan 2010 09:33:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > Thanks lots comments. 
> > hmm.. I'd like to clarily your point. My point is memory-hotplug don't take zone lock,
> > then zone lock doesn't protect anything. so we have two option
> > 
> > 1) Add zone lock to memroy-hotplug
> > 2) Remove zone lock from zoneinfo
> > 
> > I thought (2) is sufficient. Do you mean you prefer to (1)? Or you prefer to ignore rarely event
> > (of cource, memory hotplug is rarely)?
> > 
> 
> I think (2) will make zoneinfo harder to use for examining all the counters
> properly as I explained above. I haven't looked at memory-hotplug in a
> while but IIRC, fields like present_pages should be protected by a lock on
> the pgdat and a seq lock on the zone. If this is not true at the moment,
> it is a problem.
> 
> For the free lists, memory hotplug should be taking the zone->lock properly as
> the final stage of onlining memory is to walk the sections being hot-added,
> init the memmap and then __free_page() each page individually - i.e. the
> normal free path.
> 
> So, if memory hotplug is not protected by proper locking, it's not intentional.

ok, I drop this patch. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

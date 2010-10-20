Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ACB956B00B3
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:07:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K27d3L018141
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Oct 2010 11:07:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 377E145DE51
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:07:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F286645DE53
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:07:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 877231DB8059
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:07:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 04038E38002
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:07:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <20101019162940.6918506d.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1010191208130.15499@chino.kir.corp.google.com> <20101019162940.6918506d.akpm@linux-foundation.org>
Message-Id: <20101020110132.1815.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Oct 2010 11:07:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > @@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
> > >  		min_free_kbytes = 128;
> > >  	if (min_free_kbytes > 65536)
> > >  		min_free_kbytes = 65536;
> > > +
> > > +	refresh_zone_stat_thresholds();
> > >  	setup_per_zone_wmarks();
> > >  	setup_per_zone_lowmem_reserve();
> > >  	setup_per_zone_inactive_ratio();
> > 
> > setup_per_zone_wmarks() could change the min and low watermarks for a zone 
> > when refresh_zone_stat_thresholds() would have used the old value.
> 
> Indeed.
> 
> I could make the obvious fix, but then what I'd have wouldn't be
> sufficiently tested.

Can we review this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D1A366B00C2
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:35:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K2Zecg009791
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Oct 2010 11:35:41 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AB4345DE54
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:35:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 55E1D45DE4D
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:35:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 340C8E18001
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:35:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E21E9E08003
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:35:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur
In-Reply-To: <20101019192229.bae83d9d.akpm@linux-foundation.org>
References: <20101020110132.1815.A69D9226@jp.fujitsu.com> <20101019192229.bae83d9d.akpm@linux-foundation.org>
Message-Id: <20101020113500.181B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Oct 2010 11:35:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 20 Oct 2010 11:07:33 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > > @@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
> > > > >  		min_free_kbytes = 128;
> > > > >  	if (min_free_kbytes > 65536)
> > > > >  		min_free_kbytes = 65536;
> > > > > +
> > > > > +	refresh_zone_stat_thresholds();
> > > > >  	setup_per_zone_wmarks();
> > > > >  	setup_per_zone_lowmem_reserve();
> > > > >  	setup_per_zone_inactive_ratio();
> > > > 
> > > > setup_per_zone_wmarks() could change the min and low watermarks for a zone 
> > > > when refresh_zone_stat_thresholds() would have used the old value.
> > > 
> > > Indeed.
> > > 
> > > I could make the obvious fix, but then what I'd have wouldn't be
> > > sufficiently tested.
> > 
> > Can we review this?
> 
> It's unclear what you mean?
> 
> The patches otherwise look OK to me, but it's pretty easy to make
> mistakes in this area.

Ah, I misunderstood. I thought you have perfectly different approach patch.
I'll respin.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

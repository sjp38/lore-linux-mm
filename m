Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 775C76B00BC
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:22:38 -0400 (EDT)
Date: Tue, 19 Oct 2010 19:22:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [resend][PATCH 2/2] mm, mem-hotplug: update pcp->stat_threshold
 when memory hotplug occur
Message-Id: <20101019192229.bae83d9d.akpm@linux-foundation.org>
In-Reply-To: <20101020110132.1815.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1010191208130.15499@chino.kir.corp.google.com>
	<20101019162940.6918506d.akpm@linux-foundation.org>
	<20101020110132.1815.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 11:07:33 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > > @@ -5013,6 +5014,8 @@ int __meminit init_per_zone_wmark_min(void)
> > > >  		min_free_kbytes = 128;
> > > >  	if (min_free_kbytes > 65536)
> > > >  		min_free_kbytes = 65536;
> > > > +
> > > > +	refresh_zone_stat_thresholds();
> > > >  	setup_per_zone_wmarks();
> > > >  	setup_per_zone_lowmem_reserve();
> > > >  	setup_per_zone_inactive_ratio();
> > > 
> > > setup_per_zone_wmarks() could change the min and low watermarks for a zone 
> > > when refresh_zone_stat_thresholds() would have used the old value.
> > 
> > Indeed.
> > 
> > I could make the obvious fix, but then what I'd have wouldn't be
> > sufficiently tested.
> 
> Can we review this?

It's unclear what you mean?

The patches otherwise look OK to me, but it's pretty easy to make
mistakes in this area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

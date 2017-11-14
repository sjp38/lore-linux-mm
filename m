Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 312086B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:15:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 82so7374960pfp.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:15:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si17529525pfb.369.2017.11.14.07.15.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 07:15:03 -0800 (PST)
Date: Tue, 14 Nov 2017 16:14:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop hotplug lock from lru_add_drain_all
Message-ID: <20171114151459.o2b7lnogq57giiks@dhcp22.suse.cz>
References: <20171114135348.28704-1-mhocko@kernel.org>
 <alpine.DEB.2.20.1711141512180.2044@nanos>
 <20171114142347.syzyd6tlnpe2afur@dhcp22.suse.cz>
 <20171114143200.brmgskoqxjlrhrzx@dhcp22.suse.cz>
 <alpine.DEB.2.20.1711141605050.2044@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711141605050.2044@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 14-11-17 16:05:21, Thomas Gleixner wrote:
> On Tue, 14 Nov 2017, Michal Hocko wrote:
> 
> > On Tue 14-11-17 15:23:47, Michal Hocko wrote:
> > [...]
> > > +/*
> > > + * Doesn't need any cpu hotplug locking because we do rely on per-cpu
> > > + * kworkers being shut down before our page_alloc_cpu_dead callback is
> > > + * executed on the offlined cpu
> > > + */
> > >  void lru_add_drain_all(void)
> > >  {
> > >  	static DEFINE_MUTEX(lock);
> > 
> > Ble the part of the comment didn't go through
> 
> Looks good.

Thanks! I have folded that to the patch and will wait a day or two for
more comments and then resubmit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

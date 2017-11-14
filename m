Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 995036B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:11:37 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j15so11270909wre.15
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:11:37 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f2si15248901wrg.341.2017.11.14.07.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 07:11:36 -0800 (PST)
Date: Tue, 14 Nov 2017 16:11:31 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm: drop hotplug lock from lru_add_drain_all
In-Reply-To: <alpine.DEB.2.20.1711141605050.2044@nanos>
Message-ID: <alpine.DEB.2.20.1711141611070.2044@nanos>
References: <20171114135348.28704-1-mhocko@kernel.org> <alpine.DEB.2.20.1711141512180.2044@nanos> <20171114142347.syzyd6tlnpe2afur@dhcp22.suse.cz> <20171114143200.brmgskoqxjlrhrzx@dhcp22.suse.cz> <alpine.DEB.2.20.1711141605050.2044@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 14 Nov 2017, Thomas Gleixner wrote:

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

With that added, feel free to add:

Acked-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

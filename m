Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1968A6B0035
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:19:06 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so1114298pbc.27
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:19:05 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id yd9si10843771pab.205.2013.11.18.17.19.03
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 17:19:04 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id i7so3865952yha.32
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 17:19:02 -0800 (PST)
Date: Mon, 18 Nov 2013 17:19:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131118125507.GD32623@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311181717500.4292@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118125240.GC32623@dhcp22.suse.cz> <20131118125507.GD32623@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, 18 Nov 2013, Michal Hocko wrote:

> > > When current has a pending SIGKILL or is already in the exit path, it
> > > only needs access to memory reserves to fully exit.  In that sense, the
> > > memcg is not actually oom for current, it simply needs to bypass memory
> > > charges to exit and free its memory, which is guarantee itself that
> > > memory will be freed.
> > > 
> > > We only want to notify userspace for actionable oom conditions where
> > > something needs to be done (and all oom handling can already be deferred
> > > to userspace through this method by disabling the memcg oom killer with
> > > memory.oom_control), not simply when a memcg has reached its limit, which
> > > would actually have to happen before memcg reclaim actually frees memory
> > > for charges.
> > 
> > I believe this also fixes the issue reported by Eric
> > (https://lkml.org/lkml/2013/7/28/74). I had a patch for this
> > https://lkml.org/lkml/2013/7/31/94 but the code changed since then and
> > this should be equivalent.
> >  
> > > Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Anyway, the patch looks good to me but please mention the above bug in
> the changelog.
> 

The patch is in -mm, so perhaps we can change the changelog if/when Eric 
confirms it fixes his issue.

> Acked-by: Michal Hocko <mhocko@suse.cz>
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5C49A6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:23:15 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z12so423846yhz.29
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 13:23:15 -0800 (PST)
Received: from mail-gg0-x231.google.com (mail-gg0-x231.google.com [2607:f8b0:4002:c02::231])
        by mx.google.com with ESMTPS id j50si1349761yhc.100.2014.01.15.13.23.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 13:23:14 -0800 (PST)
Received: by mail-gg0-f177.google.com with SMTP id f4so641541ggn.8
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 13:23:14 -0800 (PST)
Date: Wed, 15 Jan 2014 13:23:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20140115143449.GN8782@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401151319580.10727@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com> <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <alpine.DEB.2.02.1401091324120.31538@chino.kir.corp.google.com>
 <20140109144757.e95616b4280c049b22743a15@linux-foundation.org> <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com> <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org> <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
 <20140110221432.GD6963@cmpxchg.org> <alpine.DEB.2.02.1401121404530.20999@chino.kir.corp.google.com> <20140115143449.GN8782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Wed, 15 Jan 2014, Michal Hocko wrote:

> > > > > > It was acked-by Michal.
> > > 
> > > Michal acked it before we had most of the discussions and now he is
> > > proposing an alternate version of yours, a patch that you are even
> > > discussing with him concurrently in another thread.  To claim he is
> > > still backing your patch because of that initial ack is disingenuous.
> > > 
> > 
> > His patch depends on mine, Johannes.
> 
> Does it? Are we talking about the same patch here?
> https://lkml.org/lkml/2013/12/12/174
> 

I'm happy with either patch, I suggested doing the mem_cgroup_oom_notify() 
at the last minute only when actually killing a process because of your 
concern that the oom killer would still defer.  That was addressing your 
concern as an extension of my patch which avoids unconditionally giving 
current access to memory reserves without scanning or deferring anything.  
I would be happy with either approach, and so I don't see why removing my 
patch from -mm which yours is based on would be needed.

> Which depends on yours only to revert your part. I plan to repost it but
> that still doesn't mean it will get merged because Johannes still has
> some argumnets against. I would like to start the discussion again
> because now we are so deep in circles that it is hard to come up with a
> reasonable outcome. It is still hard to e.g. agree on an actual fix
> for a real problem https://lkml.org/lkml/2013/12/12/129.
> 

This is concerning because it's merged in -mm without being tested by Eric 
and is marked for stable while violating the stable kernel rules criteria.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

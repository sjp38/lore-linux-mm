Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48BB8C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 10:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB3CE218AF
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 10:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB3CE218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 466668E0002; Fri,  1 Feb 2019 05:27:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EF198E0001; Fri,  1 Feb 2019 05:27:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B6CD8E0002; Fri,  1 Feb 2019 05:27:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAABD8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 05:27:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so2640664edb.1
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 02:27:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=W36k/e0+t7BGahkx2DT8AiFhgGtUjIl2TSrXCltWW5g=;
        b=CayU/VAZ1kPPOAEsb4yIKkUl6uSvzilN8SVY1OiBOgVYDLq0tqcxGsGZRNIxBjKeMY
         kBiYhVkARiNWwU3mL6EIhL7ldFk80FPhclq8EiGU48kH8br3DcoLP2p6VRYhN0O3S7Kg
         Crnp4qvX49H982sXgWdrbxHwLx9927GvZvLqDu6X7ILi+zYaaZVxoYZFtann9KSUah5c
         CBdtmmwoW+5mDWFcV8GByjJR6Nb0apCNUwByO52IZDp4daje6/a+qn09jsgVSolmlNW2
         29Z6NhgLLAN8BSksdS/EUjcc8mte8ir4ZMI2//OswmBwdQ5Qzy4ZWR3wdTL3S4iUvxkI
         H5ZQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcnvl8fxzo043FL3lxKeBfWjelZxO/euQDCd0FVVHHsc4HdyraC
	xWpwO8YZneNJ9AU3J71d/wsLYhSa6ync7j+HrkLfUN7FBCtWedPCthVf7rEeZ5VRfANZXThKsxv
	IGZP/se4zcUzaJAHXBxkZ2GQfhEnL5NEQ8K4z3r3Kuns/cBk8YBjj/5dHdWvYVUQ=
X-Received: by 2002:aa7:d602:: with SMTP id c2mr37782214edr.203.1549016865218;
        Fri, 01 Feb 2019 02:27:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6LUBC6/w0tcijHUdWgWUaK+os9lZGDbMhfWZJIhBTJQP+wVpssHsTbk/NTtOTC64S+7GoM
X-Received: by 2002:aa7:d602:: with SMTP id c2mr37782134edr.203.1549016863766;
        Fri, 01 Feb 2019 02:27:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549016863; cv=none;
        d=google.com; s=arc-20160816;
        b=UpcgfwpbltNprRZFVCXwQ4FEvP/JaPcZMW35NQ9q4N9xRqGu04MklQRrQ14v2irIHC
         o5RRD+kRvTnk6GrOEiIqTlu+REa39r3EPNfHzoxDyB38qDgRm+1JitjDHxolemU3WLXx
         RYyi76yWaxW2hREFeYW6wSk1eucCdVeRok2k5bQ6Q03YcsqKbLkYdph2SsfbarzVMvmE
         o3LpnmtQ5kXAhYNynpgad2semwrWHgVHimGR6Hk3nHRZYacPMVbmOnosZA6ADyImNuhg
         gV4PJ1sVJaMdsu7+j7NF2M7VIVfM4BJOip6I/glqDs9cyZKM8LRBKxXW8g9mYQ55J178
         8XpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=W36k/e0+t7BGahkx2DT8AiFhgGtUjIl2TSrXCltWW5g=;
        b=QHPQUOQMIe0h6dBmD+ka0ivgG/m2/zgErrXGKZcYpS7PungtfndeWIq1e6zSoyHHn7
         02fgW6dOXQM57Bp+dK7s9CmvMIdeXvI3Dh7tJiTlivhuHkFMGYc7o2+Vw2IqE53Nolv3
         rNkQ8EbemW/HZfJxr9bbVRKy1rsoozwlMgyRW5DEo0PieXUIL26RzQTSIhpKZ4GGKCJP
         2jZWTbrh0i60RRwSRbh12ichgYa4eNLI7Bu2oHybZgmh3ZaVy07eCgmC7INTsPIitq44
         ZYzY7Zocl14Ml6J7RPSpnv9u3VNGnF52e0Kth+/kssHQCr5J3ZgJttumviLJlUIbHBBm
         AKfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si54522ejj.148.2019.02.01.02.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 02:27:43 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 08A2BAD4A;
	Fri,  1 Feb 2019 10:27:43 +0000 (UTC)
Date: Fri, 1 Feb 2019 11:27:41 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190201102515.GK11599@dhcp22.suse.cz>
References: <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190130192345.GA20957@cmpxchg.org>
 <20190130200559.GI18811@dhcp22.suse.cz>
 <20190130213131.GA13142@cmpxchg.org>
 <20190131085808.GO18811@dhcp22.suse.cz>
 <20190131162248.GA17354@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131162248.GA17354@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 11:22:48, Johannes Weiner wrote:
> On Thu, Jan 31, 2019 at 09:58:08AM +0100, Michal Hocko wrote:
> > On Wed 30-01-19 16:31:31, Johannes Weiner wrote:
> > > On Wed, Jan 30, 2019 at 09:05:59PM +0100, Michal Hocko wrote:
> > [...]
> > > > I thought I have already mentioned an example. Say you have an observer
> > > > on the top of a delegated cgroup hierarchy and you setup limits (e.g. hard
> > > > limit) on the root of it. If you get an OOM event then you know that the
> > > > whole hierarchy might be underprovisioned and perform some rebalancing.
> > > > Now you really do not care that somewhere down the delegated tree there
> > > > was an oom. Such a spurious event would just confuse the monitoring and
> > > > lead to wrong decisions.
> > > 
> > > You can construct a usecase like this, as per above with OOM, but it's
> > > incredibly unlikely for something like this to exist. There is plenty
> > > of evidence on adoption rate that supports this: we know where the big
> > > names in containerization are; we see the things we run into that have
> > > not been reported yet etc.
> > > 
> > > Compare this to real problems this has already caused for
> > > us. Multi-level control and monitoring is a fundamental concept of the
> > > cgroup design, so naturally our infrastructure doesn't monitor and log
> > > at the individual job level (too much data, and also kind of pointless
> > > when the jobs are identical) but at aggregate parental levels.
> > > 
> > > Because of this wart, we have missed problematic configurations when
> > > the low, high, max events were not propagated as expected (we log oom
> > > separately, so we still noticed those). Even once we knew about it, we
> > > had trouble tracking these configurations down for the same reason -
> > > the data isn't logged, and won't be logged, at this level.
> > 
> > Yes, I do understand that you might be interested in the hierarchical
> > accounting.
> > 
> > > Adding a separate, hierarchical file would solve this one particular
> > > problem for us, but it wouldn't fix this pitfall for all future users
> > > of cgroup2 (which by all available evidence is still most of them) and
> > > would be a wart on the interface that we'd carry forever.
> > 
> > I understand even this reasoning but if I have to chose between a risk
> > of user breakage that would require to reimplement the monitoring or an
> > API incosistency I vote for the first option. It is unfortunate but this
> > is the way we deal with APIs and compatibility.
> 
> I don't know why you keep repeating this, it's simply not how Linux
> API is maintained in practice.
> 
> In cgroup2, we fixed io.stat to not conflate discard IO and write IO:
> 636620b66d5d4012c4a9c86206013964d3986c4f
> 
> Linus changed the Vmalloc field semantics in /proc/meminfo after over
> a decade, without a knob to restore it in production:
> 
>     If this breaks anything, we'll obviously have to re-introduce the code
>     to compute this all and add the caching patches on top.  But if given
>     the option, I'd really prefer to just remove this bad idea entirely
>     rather than add even more code to work around our historical mistake
>     that likely nobody really cares about.
>     a5ad88ce8c7fae7ddc72ee49a11a75aa837788e0
> 
> Mel changed the zone_reclaim_mode default behavior after over a
> decade:
> 
>     Those that require zone_reclaim_mode are likely to be able to
>     detect when it needs to be enabled and tune appropriately so lets
>     have a sensible default for the bulk of users.
>     4f9b16a64753d0bb607454347036dc997fd03b82
>     Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> And then Mel changed the default zonelist ordering to pick saner
> behavior for most users, followed by a complete removal of the zone
> list ordering, after again, decades of existence of these things:
> 
>     commit c9bff3eebc09be23fbc868f5e6731666d23cbea3
>     Author: Michal Hocko <mhocko@suse.com>
>     Date:   Wed Sep 6 16:20:13 2017 -0700
> 
>         mm, page_alloc: rip out ZONELIST_ORDER_ZONE
> 
> And why did we do any of those things and risk user disruption every
> single time? Because the existing behavior was not a good default, a
> burden on people, and the risk of breakage was sufficiently low.
> 
> I don't see how this case is different, and you haven't provided any
> arguments that would explain that.

Because there is no simple way to revert in _this_ particular case. Once
you change the semantic of the file you cannot simply make it
non-hierarchical after somebody complains. You do not want to break both
worlds. See the difference?

[...]
> > Those users requiring the hierarchical beahvior can use the new file
> > without any risk of breakages so I really do not see why we should
> > undertake the risk and do it the other way around.
> 
> Okay, so let's find a way forward here.
> 
> 1. A new memory.events_tree file or similar. This would give us a way
> to get the desired hierarchical behavior. The downside is that it's
> suggesting that ${x} and ${x}_tree are the local and hierarchical
> versions of a cgroup file, and that's false everywhere else. Saying we
> would document it is a cop-out and doesn't actually make the interface
> less confusing (most people don't look at errata documentation until
> they've been burned by unexpected behavior).
> 
> 2. A runtime switch (cgroup mount option, sysctl, what have you) that
> lets you switch between the local and the tree behavior. This would be
> able to provide the desired semantics in a clean interface, while
> still having the ability to support legacy users.

With an obvious downside that one or the other usecase has to learn that
the current semantic is different than expected which is again something
that has to be documented so we are in the same "people don't look at
errata documentation...". Another obvious problem is that you might have
two workloads with different semantic expectations and then this option
simply falls flat.

> 2a. A runtime switch that defaults to the local behavior.
> 
> 2b. A runtime switch that defaults to the tree behavior.
> 
> The choice between 2a and 2b comes down to how big we evaluate the
> risk that somebody has an existing dependency on the local behavior.
> 
> Given what we know about cgroup2 usage, and considering our previous
> behavior in such matters, I'd say 2b is reasonable and in line with
> how we tend to handle these things. On the tiny chance that somebody
> is using the current behavior, they can flick the switch (until we add
> the .local files, or simply use the switch forever).

My preference is 1 but if there is a _larger_ consensus of different
cgroup v2  users that 2 is more preferred then I can live with that.
-- 
Michal Hocko
SUSE Labs


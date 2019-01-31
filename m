Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ABF1C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D397218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:22:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0rtgpPE0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D397218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFC388E0004; Thu, 31 Jan 2019 11:22:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAAA78E0003; Thu, 31 Jan 2019 11:22:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A99AD8E0004; Thu, 31 Jan 2019 11:22:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 802488E0003
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:22:52 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id p8so2085611ybb.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:22:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wE2aRl4Gjx5VjDxdFAhUakdsREIMx7y7W6lKaBxreOw=;
        b=Oem8h96Y992mXsR3Jk/tvDT8pI6SVQ9ZWSrv4MHMT2oGjUL0uXeepI6UDZf5TDFvhe
         ZDN7bDQE+SsMzU+guz+fA6mlv1Jc1f6Et9YxHehmeG+kPiHkL3t2bgZvThBCIPeQwAxF
         L+7yffLVYTEQoxyo+cOMpakGi3kuMsZusWQ0CSvnO5qWwN5K1nGj0bFzpOKhBHGNeCtU
         L+HvItgOGNwSbDWYTxAHWXC54w5q1nKVihEKxVO6zOIZvKWa6/Q8wLj0Wy0NZi+NDgf7
         ew7i96q3aCnPx7qoUdakd49VBLmw1egef8XOzT1uuruuUzu5wVIOvtbNlhDR4xoK5eSD
         b9ZQ==
X-Gm-Message-State: AJcUukfV1CpXG3wkEXPfYbAGp6Z51mpIXPbu4UW6oRK6fE9r73iC52gX
	soOzKnLC975ubnbdtjbgl1Q9s+YJVxmtafeWwDYAwMaooRyukS99t9QYsaAqSkuI6lUoDww7f5H
	uljqIzxZWJCcBKEhXKcw2UeJzKcP8KLHlYdkQmxOegR833t0S3uR2pZ1TNDD4GQAbqAestdw5ig
	xPREL+MtNVH+aROSgPzinFDrrHoOPsQapIh/GX/w82B/si27NAr9RX7v4z0F82gCbDz2pFU5Yic
	6JFChDP/ht7mdaemJ1Rgf4DsRac8h38mYEPtMg33JwM2jPfQGVnL1fG3LLlYshL0/YyrtJApm0p
	X9pBzRDIlrydUojzTKZH1iayWnouFiW/W/G1aKlokLMvMC0siakY82vYH04QYOR4Z/eAHvtDtDO
	g
X-Received: by 2002:a5b:50b:: with SMTP id o11mr34294112ybp.285.1548951772153;
        Thu, 31 Jan 2019 08:22:52 -0800 (PST)
X-Received: by 2002:a5b:50b:: with SMTP id o11mr34294023ybp.285.1548951770976;
        Thu, 31 Jan 2019 08:22:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548951770; cv=none;
        d=google.com; s=arc-20160816;
        b=sIDNmohuS5LtSwNN8sczFmS0dMfZbgpwjbHuJz1zmU33moOgenJNrm+kezKl79ulSc
         feZH0At0oJGdbk9uf15Dk/ZMkEheEjOqCGDjrGhiSfvGpB/PqzDm+9nqBCDF9FnRl3sQ
         E3JKLaaJbA23g2uv017RLa83+2um524TD2MlEuRHY1TjVbBcbzx11LkVh1H+Oy45kZpA
         lVzYf1iwo2N38n+SD9mpNqi0sF/fog3Tnd9In90rmaVEFCRGEvkLwBaNtKTFlGuEa7LJ
         wt3F7tx+rUSJciLwDtZwwKOu4oo7sWoY8cZU2tl/PMlTGDGl7B7pOmwUFxyPs0HXt7gA
         evqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wE2aRl4Gjx5VjDxdFAhUakdsREIMx7y7W6lKaBxreOw=;
        b=IvJoFnJr3nk6Lzxs7ZCiOdWdghwTuag6K8nKk5I4yY92gGn3qOlIuUAiBT24aFq/LN
         UT6LRLGgMzAX8SUBZX6vbZkoeE2kWe1Fbn7wReTvLOxQfimcztRvpIs9VRnfwutty8rt
         tFt/M1JeH1dtL2iFZ2e/QgPGS/znzaZBqtXqU38N9YgAjyOWjwULPZIYf8DRa8hxsrZY
         9Uz454dlK51v/VdbGLRW2urNXr3pPAA4lX8WFL8WaFuFOJS/PqROjqPtSDq9YyttwcxB
         HZ8HFfl+gULeWxBP3TcE88mGUWahceB1azw4oYZic53cwjIZ6xGR4KNfCvsj8fGl3Ewo
         61fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0rtgpPE0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t124sor688259ywb.103.2019.01.31.08.22.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 08:22:50 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0rtgpPE0;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wE2aRl4Gjx5VjDxdFAhUakdsREIMx7y7W6lKaBxreOw=;
        b=0rtgpPE0g4au+NVj91KUAPTbdwe5t34WNXNZTqBfjBzIZNnwPYO6rW2J51SVnzZFOs
         BNG+tu2XURHJiNSJdqsO4KRcLJUdl5egJ5lxzfyp51h9DahrDRofAi6xQUzqcWME/moM
         GEZYhCoGcc/hWFWTMYeHXoNenRGx2HVIxbfwe04JNo8Mo2Mwzl3v0B0PcgAkpbQuZiqC
         w3F8tUT6Dr1ZjFhwSd1rEmmjOGzyg1DhqH1NcFCiwZf8f8vY1bqJkhSyZi8Nd/EdGHCt
         LDhV1Msb3+4G2ttFqIwYk7Q5SBcdl/C0xaRT8cWDWZJMBwwB++D6WgRW0sgvK07bnHhh
         tiTQ==
X-Google-Smtp-Source: ALg8bN4wp9NoIj9DgnKnqveg+P4bpJ/ATDCWU5WqLAXI2wZoSl3d1+BQjlnRWMFMwgLGHssggHUqYg==
X-Received: by 2002:a81:6c51:: with SMTP id h78mr33955264ywc.116.1548951770271;
        Thu, 31 Jan 2019 08:22:50 -0800 (PST)
Received: from localhost ([2620:10d:c091:180::1:80c2])
        by smtp.gmail.com with ESMTPSA id y1sm1948347ywe.86.2019.01.31.08.22.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 08:22:49 -0800 (PST)
Date: Thu, 31 Jan 2019 11:22:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190131162248.GA17354@cmpxchg.org>
References: <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190130192345.GA20957@cmpxchg.org>
 <20190130200559.GI18811@dhcp22.suse.cz>
 <20190130213131.GA13142@cmpxchg.org>
 <20190131085808.GO18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131085808.GO18811@dhcp22.suse.cz>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:58:08AM +0100, Michal Hocko wrote:
> On Wed 30-01-19 16:31:31, Johannes Weiner wrote:
> > On Wed, Jan 30, 2019 at 09:05:59PM +0100, Michal Hocko wrote:
> [...]
> > > I thought I have already mentioned an example. Say you have an observer
> > > on the top of a delegated cgroup hierarchy and you setup limits (e.g. hard
> > > limit) on the root of it. If you get an OOM event then you know that the
> > > whole hierarchy might be underprovisioned and perform some rebalancing.
> > > Now you really do not care that somewhere down the delegated tree there
> > > was an oom. Such a spurious event would just confuse the monitoring and
> > > lead to wrong decisions.
> > 
> > You can construct a usecase like this, as per above with OOM, but it's
> > incredibly unlikely for something like this to exist. There is plenty
> > of evidence on adoption rate that supports this: we know where the big
> > names in containerization are; we see the things we run into that have
> > not been reported yet etc.
> > 
> > Compare this to real problems this has already caused for
> > us. Multi-level control and monitoring is a fundamental concept of the
> > cgroup design, so naturally our infrastructure doesn't monitor and log
> > at the individual job level (too much data, and also kind of pointless
> > when the jobs are identical) but at aggregate parental levels.
> > 
> > Because of this wart, we have missed problematic configurations when
> > the low, high, max events were not propagated as expected (we log oom
> > separately, so we still noticed those). Even once we knew about it, we
> > had trouble tracking these configurations down for the same reason -
> > the data isn't logged, and won't be logged, at this level.
> 
> Yes, I do understand that you might be interested in the hierarchical
> accounting.
> 
> > Adding a separate, hierarchical file would solve this one particular
> > problem for us, but it wouldn't fix this pitfall for all future users
> > of cgroup2 (which by all available evidence is still most of them) and
> > would be a wart on the interface that we'd carry forever.
> 
> I understand even this reasoning but if I have to chose between a risk
> of user breakage that would require to reimplement the monitoring or an
> API incosistency I vote for the first option. It is unfortunate but this
> is the way we deal with APIs and compatibility.

I don't know why you keep repeating this, it's simply not how Linux
API is maintained in practice.

In cgroup2, we fixed io.stat to not conflate discard IO and write IO:
636620b66d5d4012c4a9c86206013964d3986c4f

Linus changed the Vmalloc field semantics in /proc/meminfo after over
a decade, without a knob to restore it in production:

    If this breaks anything, we'll obviously have to re-introduce the code
    to compute this all and add the caching patches on top.  But if given
    the option, I'd really prefer to just remove this bad idea entirely
    rather than add even more code to work around our historical mistake
    that likely nobody really cares about.
    a5ad88ce8c7fae7ddc72ee49a11a75aa837788e0

Mel changed the zone_reclaim_mode default behavior after over a
decade:

    Those that require zone_reclaim_mode are likely to be able to
    detect when it needs to be enabled and tune appropriately so lets
    have a sensible default for the bulk of users.
    4f9b16a64753d0bb607454347036dc997fd03b82
    Acked-by: Michal Hocko <mhocko@suse.cz>

And then Mel changed the default zonelist ordering to pick saner
behavior for most users, followed by a complete removal of the zone
list ordering, after again, decades of existence of these things:

    commit c9bff3eebc09be23fbc868f5e6731666d23cbea3
    Author: Michal Hocko <mhocko@suse.com>
    Date:   Wed Sep 6 16:20:13 2017 -0700

        mm, page_alloc: rip out ZONELIST_ORDER_ZONE

And why did we do any of those things and risk user disruption every
single time? Because the existing behavior was not a good default, a
burden on people, and the risk of breakage was sufficiently low.

I don't see how this case is different, and you haven't provided any
arguments that would explain that.

> > Adding a note in cgroup-v2.txt doesn't make up for the fact that this
> > behavior flies in the face of basic UX concepts that underly the
> > hierarchical monitoring and control idea of the cgroup2fs.
> > 
> > The fact that the current behavior MIGHT HAVE a valid application does
> > not mean that THIS FILE should be providing it. It IS NOT an argument
> > against this patch here, just an argument for a separate patch that
> > adds this functionality in a way that is consistent with the rest of
> > the interface (e.g. systematically adding .local files).
> > 
> > The current semantics have real costs to real users. You cannot
> > dismiss them or handwave them away with a hypothetical regression.
> > 
> > I would really ask you to consider the real world usage and adoption
> > data we have on cgroup2, rather than insist on a black and white
> > answer to this situation.
> 
> Those users requiring the hierarchical beahvior can use the new file
> without any risk of breakages so I really do not see why we should
> undertake the risk and do it the other way around.

Okay, so let's find a way forward here.

1. A new memory.events_tree file or similar. This would give us a way
to get the desired hierarchical behavior. The downside is that it's
suggesting that ${x} and ${x}_tree are the local and hierarchical
versions of a cgroup file, and that's false everywhere else. Saying we
would document it is a cop-out and doesn't actually make the interface
less confusing (most people don't look at errata documentation until
they've been burned by unexpected behavior).

2. A runtime switch (cgroup mount option, sysctl, what have you) that
lets you switch between the local and the tree behavior. This would be
able to provide the desired semantics in a clean interface, while
still having the ability to support legacy users.

2a. A runtime switch that defaults to the local behavior.

2b. A runtime switch that defaults to the tree behavior.

The choice between 2a and 2b comes down to how big we evaluate the
risk that somebody has an existing dependency on the local behavior.

Given what we know about cgroup2 usage, and considering our previous
behavior in such matters, I'd say 2b is reasonable and in line with
how we tend to handle these things. On the tiny chance that somebody
is using the current behavior, they can flick the switch (until we add
the .local files, or simply use the switch forever).


Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D781C8E00DF
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:28:12 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v131so5418880ywb.19
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:28:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m189sor7716341ybc.5.2019.01.25.10.28.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 10:28:11 -0800 (PST)
Date: Fri, 25 Jan 2019 10:28:08 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190125182808.GL50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125173713.GD20411@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Fri, Jan 25, 2019 at 06:37:13PM +0100, Michal Hocko wrote:
> > What if a user wants to monitor any ooms in the subtree tho, which is
> > a valid use case?
> 
> How is that information useful without know which memcg the oom applies
> to?

For example, a workload manager watching over a subtree for a job with
nested memory limits set by the job itself.  It wants to take action
(reporting and possibly other remediative actions) when something goes
wrong in the delegated subtree but isn't involved in how the subtree
is configured inside.

> > If local event monitoring is useful and it can be,
> > let's add separate events which are clearly identifiable to be local.
> > Right now, it's confusing like hell.
> 
> From a backward compatible POV it should be a new interface added.

That sure is an option for use cases like above but it has the
downside of carrying over the confusing interface into the indefinite
future.  Again, I'd like to point back at how we changed the
accounting write and trim accounting because the benefits outweighted
the risks.

> Please note that I understand that this might be confusing with the rest
> of the cgroup APIs but considering that this is the first time somebody
> is actually complaining and the interface is "production ready" for more
> than three years I am not really sure the situation is all that bad.

cgroup2 uptake hasn't progressed that fast.  None of the major distros
or container frameworks are currently shipping with it although many
are evaluating switching.  I don't think I'm too mistaken in that we
(FB) are at the bleeding edge in terms of adopting cgroup2 and its
various new features and are hitting these corner cases and oversights
in the process.  If there are noticeable breakages arising from this
change, we sure can backpaddle but I think the better course of action
is fixing them up while we can.

Thanks.

-- 
tejun

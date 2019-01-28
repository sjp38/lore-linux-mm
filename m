Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 817038E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:28:22 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id v131so9661444ywb.19
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:28:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r127sor6311475ybf.189.2019.01.28.06.28.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:28:21 -0800 (PST)
Date: Mon, 28 Jan 2019 06:28:16 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128142816.GM50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128125151.GI18811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Mon, Jan 28, 2019 at 01:51:51PM +0100, Michal Hocko wrote:
> > For example, a workload manager watching over a subtree for a job with
> > nested memory limits set by the job itself.  It wants to take action
> > (reporting and possibly other remediative actions) when something goes
> > wrong in the delegated subtree but isn't involved in how the subtree
> > is configured inside.
> 
> Yes, I understand this part, but it is not clear to me, _how_ to report
> anything sensible without knowing _what_ has caused the event. You can
> walk the cgroup hierarchy and compare cached results with new ones but
> this is a) racy and b) clumsy.

All .events files generate aggregated stateful notifications.  For
anyone to do anything, they'd have to remember the previous state to
identify what actually happened.  Being hierarchical, it'd of course
need to walk down when an event triggers.

> > That sure is an option for use cases like above but it has the
> > downside of carrying over the confusing interface into the indefinite
> > future.
> 
> I actually believe that this is not such a big deal. For one thing the
> current events are actually helpful to watch the reclaim/setup behavior.

Sure, it isn't something critical.  It's just confusing and I think
it'd be better to improve.

> I do not really think you can go back. You cannot simply change semantic
> back and forth because you just break new users.
> 
> Really, I do not see the semantic changing after more than 3 years of
> production ready interface. If you really believe we need a hierarchical
> notification mechanism for the reclaim activity then add a new one.

I don't see it as black and white as you do.  Let's agree to disagree.
I'll ack the patch and note the disagreement.

Thanks.

-- 
tejun

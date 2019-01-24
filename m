Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D76F8E0085
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 11:00:19 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id n1so2963989ybd.10
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 08:00:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 80sor2969482ywo.85.2019.01.24.08.00.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 08:00:12 -0800 (PST)
Date: Thu, 24 Jan 2019 11:00:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190124160009.GA12436@cmpxchg.org>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124082252.GD4087@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, Jan 24, 2019 at 09:22:52AM +0100, Michal Hocko wrote:
> On Wed 23-01-19 17:31:44, Chris Down wrote:
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> btw. I do not see this patch posted anywhere yet it already comes with
> an ack. Have I just missed a previous version?

I reviewed it offline before Chris sent it out.

I agree with the sentiment that the non-hierarchical behavior was an
oversight, not a design decision.

The arguments against the change don't convince me: the added
difficulty of finding out local values is true for all other cgroup
files as well. This is traded off with being able to detect any
subtree state from the first level cgroups and drill down on-demand,
without having to scan the entire tree on each monitoring interval.
That's a trade-off we've made everywhere else, so this is simply an
inconsistency, not a legitimate exception to the rule.

We cannot fully eliminate a risk for regression, but it strikes me as
highly unlikely, given the extremely young age of cgroup2-based system
management and surrounding tooling.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

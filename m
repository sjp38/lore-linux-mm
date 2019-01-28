From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Date: Mon, 28 Jan 2019 09:49:05 -0800
Message-ID: <20190128174905.GU50184@devbig004.ftw2.facebook.com>
References: <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190128170526.GQ18811@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
List-Id: linux-mm.kvack.org

Hello, Michal.

On Mon, Jan 28, 2019 at 06:05:26PM +0100, Michal Hocko wrote:
> Yeah, that is quite clear. But it also assumes that the hierarchy is
> pretty stable but cgroups might go away at any time. I am not saying
> that the aggregated events are not useful I am just saying that it is
> quite non-trivial to use and catch all potential corner cases. Maybe I

It really isn't complicated and doesn't require stable subtree.

> am overcomplicating it but one thing is quite clear to me. The existing
> semantic is really useful to watch for the reclaim behavior at the
> current level of the tree. You really do not have to care what is
> happening in the subtree when it is clear that the workload itself
> is underprovisioned etc. Considering that such a semantic already
> existis, somebody might depend on it and we likely want also aggregated
> semantic then I really do not see why to risk regressions rather than
> add a new memory.hierarchy_events and have both.

The problem then is that most other things are hierarchical including
some fields in .events files, so if we try to add local stats and
events, there's no good way to add them.

Thanks.

-- 
tejun

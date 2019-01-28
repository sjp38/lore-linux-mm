From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Date: Mon, 28 Jan 2019 08:05:12 -0800
Message-ID: <20190128160512.GR50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALvZod6LFY+FYfBcAX0kLxV5KKB1-TX2cU5EDyyyjvHOtuWWbA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kernel-team@fb.com
List-Id: linux-mm.kvack.org

Hello, Shakeel.

On Mon, Jan 28, 2019 at 07:59:33AM -0800, Shakeel Butt wrote:
> Why not make this configurable at the delegation boundary? As you
> mentioned, there are jobs who want centralized workload manager to
> watch over their subtrees while there can be jobs which want to
> monitor their subtree themselves. For example I can have a job which
> know how to act when one of the children cgroup goes OOM. However if
> the root of that job goes OOM then the centralized workload manager
> should do something about it. With this change, how to implement this
> scenario? How will the central manager differentiates between that a
> subtree of a job goes OOM or the root of that job? I guess from the
> discussion it seems like the centralized manager has to traverse that
> job's subtree to find the source of OOM.
> 
> Why can't we let the implementation of centralized manager easier by
> allowing to configure the propagation of these notifications across
> delegation boundary.

I think the right way to achieve the above would be having separate
recursive and local counters.

Thanks.

-- 
tejun

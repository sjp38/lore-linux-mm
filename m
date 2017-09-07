From: Christopher Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Date: Thu, 7 Sep 2017 11:18:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709071114560.20082@nuc-kabylake>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-3-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170904142108.7165-3-guro-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roman Gushchin <guro-b10kYP2dOMg@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Vladimir Davydov <vdavydov.dev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: linux-mm.kvack.org

On Mon, 4 Sep 2017, Roman Gushchin wrote

> To address these issues, cgroup-aware OOM killer is introduced.

You are missing a major issue here. Processes may have allocation
constraints to memory nodes, special DMA zones etc etc. OOM conditions on
such resource constricted allocations need to be dealt with. Killing
processes that do not allocate with the same restrictions may not do
anything to improve conditions.

> But a user can change this behavior by enabling the per-cgroup
> oom_kill_all_tasks option. If set, it causes the OOM killer treat
> the whole cgroup as an indivisible memory consumer. In case if it's
> selected as on OOM victim, all belonging tasks will be killed.

Sounds good in general. Unless the cgroup or processes therein run out of
memory due to memory access restrictions. How do you detect that and how
it is handled?

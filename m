From: Christopher Lameter <cl@linux.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Date: Fri, 8 Sep 2017 16:07:21 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709081601310.27965@nuc-kabylake>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905215344.GA27427@cmpxchg.org> <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz> <alpine.DEB.2.20.1709071122360.20082@nuc-kabylake>
 <alpine.DEB.2.10.1709071502430.143767@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1709071502430.143767@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 7 Sep 2017, David Rientjes wrote:

> > It has *nothing* to do with zillions of tasks. Its amusing that the SGI
> > ghost is still haunting the discussion here. The company died a couple of
> > years ago finally (ok somehow HP has an "SGI" brand now I believe). But
> > there are multiple companies that have large NUMA configurations and they
> > all have configurations where they want to restrict allocations of a
> > process to subset of system memory. This is even more important now that
> > we get new forms of memory (NVDIMM, PCI-E device memory etc). You need to
> > figure out what to do with allocations that fail because the *allowed*
> > memory pools are empty.
> >
>
> We already had CONSTRAINT_CPUSET at the time, this was requested by Paul
> and acked by him in https://marc.info/?l=linux-mm&m=118306851418425.

Ok. Certainly there were scalability issues (lots of them) and the sysctl
may have helped there if set globally. But the ability to kill the
allocating tasks was primarily used in cpusets for constrained allocation.

The issue of scaling is irrelevant in the context of deciding what to do
about the sysctl. You can address the issue differently if it still
exists. The systems with super high NUMA nodes (hundreds to a
thousand) have somehow fallen out of fashion a bit. So I doubt that this
is still an issue. And no one of the old stakeholders is speaking up.

What is the current approach for an OOM occuring in a cpuset or cgroup
with a restricted numa node set?

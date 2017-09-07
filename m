From: Christopher Lameter <cl@linux.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Date: Thu, 7 Sep 2017 11:27:30 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709071122360.20082@nuc-kabylake>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905215344.GA27427@cmpxchg.org> <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Wed, 6 Sep 2017, Michal Hocko wrote:

> I am not sure this is how things evolved actually. This is way before
> my time so my git log interpretation might be imprecise. We do have
> oom_badness heuristic since out_of_memory has been introduced and
> oom_kill_allocating_task has been introduced much later because of large
> boxes with zillions of tasks (SGI I suspect) which took too long to
> select a victim so David has added this heuristic.

Nope. The logic was required for tasks that run out of memory when the
restriction on the allocation did not allow the use of all of memory.
cpuset restrictions and memory policy restrictions where the prime
considerations at the time.

It has *nothing* to do with zillions of tasks. Its amusing that the SGI
ghost is still haunting the discussion here. The company died a couple of
years ago finally (ok somehow HP has an "SGI" brand now I believe). But
there are multiple companies that have large NUMA configurations and they
all have configurations where they want to restrict allocations of a
process to subset of system memory. This is even more important now that
we get new forms of memory (NVDIMM, PCI-E device memory etc). You need to
figure out what to do with allocations that fail because the *allowed*
memory pools are empty.

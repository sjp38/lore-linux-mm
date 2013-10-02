From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [patch for-3.12] mm, memcg: protect mem_cgroup_read_events for
 cpu hotplug
Date: Tue, 1 Oct 2013 22:22:27 -0400
Message-ID: <20131002022227.GR856@cmpxchg.org>
References: <alpine.DEB.2.02.1310011629350.27758@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1310011629350.27758-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: linux-mm.kvack.org

On Tue, Oct 01, 2013 at 04:31:23PM -0700, David Rientjes wrote:
> for_each_online_cpu() needs the protection of {get,put}_online_cpus() so
> cpu_online_mask doesn't change during the iteration.

There is no problem report here.

Is there a crash?

If it's just accuracy of the read, why would we care about some
inaccuracies in counters that can change before you even get the
results to userspace?  And care to the point where we hold up CPU
hotplugging for this?

Also, the fact that you directly sent this to Linus suggests there is
some urgency for this fix.  What's going on?

Thanks,
Johannes

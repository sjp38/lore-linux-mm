Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D43846B0062
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:41 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 0/5] forced comounts for cgroups.
Date: Tue,  4 Sep 2012 18:18:15 +0400
Message-Id: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org

Hi,

As we have been extensively discussing, the cost and pain points for cgroups
come from many places. But at least one of those is the arbitrary nature of
hierarchies. Many people, including at least Tejun and me would like this to go
away altogether. Problem so far, is breaking compatiblity with existing setups

I am proposing here a default-n Kconfig option that will guarantee that the cpu
cgroups (for now) will be comounted. I started with them because the
cpu/cpuacct division is clearly the worst offender. Also, the default-n is here
so distributions will have time to adapt: Forcing this flag to be on without
userspace changes will just lead to cgroups failing to mount, which we don't
want.

Although I've tested it and it works, I haven't compile-tested all possible
config combinations. So this is mostly for your eyes. If this gets traction,
I'll submit it properly, along with any changes that you might require.

Thanks.

Glauber Costa (5):
  cgroup: allow some comounts to be forced.
  sched: adjust exec_clock to use it as cpu usage metric
  sched: do not call cpuacct_charge when cpu and cpuacct are comounted
  cpuacct: do not gather cpuacct statistics when not mounted
  sched: add cpusets to comounts list

 include/linux/cgroup.h |   6 ++
 init/Kconfig           |  23 ++++++++
 kernel/cgroup.c        |  29 +++++++++-
 kernel/cpuset.c        |   4 ++
 kernel/sched/core.c    | 149 +++++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/rt.c      |   1 +
 kernel/sched/sched.h   |  20 ++++++-
 7 files changed, 220 insertions(+), 12 deletions(-)

-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

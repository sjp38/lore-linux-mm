Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1C0CA6B00DA
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 09:09:39 -0400 (EDT)
Date: Wed, 12 Sep 2012 15:09:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
Message-ID: <20120912130935.GJ21579@dhcp22.suse.cz>
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
 <20120911095200.GB8058@dhcp22.suse.cz>
 <20120912072520.GB17516@dhcp22.suse.cz>
 <50504CE1.8030509@parallels.com>
 <20120912125647.GH21579@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912125647.GH21579@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Sachin Kamat <sachin.kamat@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 12-09-12 14:56:47, Michal Hocko wrote:
> On Wed 12-09-12 12:50:41, Glauber Costa wrote:
> [...]
> > >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > >> index 795e525..85ec9ff 100644
> > >> --- a/mm/memcontrol.c
> > >> +++ b/mm/memcontrol.c
> > >> @@ -50,8 +50,12 @@
> > >>  #include <linux/cpu.h>
> > >>  #include <linux/oom.h>
> > >>  #include "internal.h"
> > >> +
> > >> +#ifdef CONFIG_MEMCG_KMEM
> > >>  #include <net/sock.h>
> > >> +#include <net/ip.h>
> > >>  #include <net/tcp_memcontrol.h>
> > >> +#endif
> > >>  
> > >>  #include <asm/uaccess.h>
> > >>  
> > >> @@ -326,7 +330,7 @@ struct mem_cgroup {
> > >>  	struct mem_cgroup_stat_cpu nocpu_base;
> > >>  	spinlock_t pcp_counter_lock;
> > >>  
> > >> -#ifdef CONFIG_INET
> > >> +#ifdef CONFIG_MEMCG_KMEM
> > >>  	struct tcp_memcontrol tcp_mem;
> > >>  #endif
> > >>  };
> > 
> > If you are changing this, why not test for both? This field will be
> > useless with inet disabled. I usually don't like conditional in
> > structures (note that the "kmem" res counter in my patchsets is not
> > conditional to KMEM!!), but since the decision was made to make this one
> > conditional, I think INET is a much better test. I am fine with both though.
>  
>  You are right of course. Updated patch bellow:

Bahh. And I managed to send a different patch than I tested...
---

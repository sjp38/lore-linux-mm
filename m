Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 584016B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:25:47 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so3007356wma.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:25:47 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id t14si1134635wme.122.2016.11.22.23.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 23:25:46 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id m203so848372wma.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:25:45 -0800 (PST)
Date: Wed, 23 Nov 2016 08:25:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm v2 0/3] Support memory cgroup hotplug
Message-ID: <20161123072543.GD2864@dhcp22.suse.cz>
References: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479875814-11938-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 23-11-16 15:36:51, Balbir Singh wrote:
> In the absence of hotplug we use extra memory proportional to
> (possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
> to disable large consumption with large number of cgroups. This patch
> adds hotplug support to memory cgroups and reverts the commit that
> limited possible nodes to online nodes.

Balbir,
I have asked this in the previous version but there still seems to be a
lack of information of _why_ do we want this, _how_ much do we save on
the memory overhead on most systems and _why_ the additional complexity
is really worth it. Please make sure to add all this in the cover
letter.

I still didn't get to look into those patches because I am swamped with
other things but to be honest I do not really see a strong justification
to make it high priority for me.

> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org> 
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> 
> I've tested this patches under a VM with two nodes and movable
> nodes enabled. I've offlined nodes and checked that the system
> and cgroups with tasks deep in the hierarchy continue to work
> fine.
> 
> These patches are on top of linux-next (20161117)
> 
> Changelog v2:
> 	Add get/put_online_mems() around node iteration
> 	Use MEM_OFFLINE/MEM_ONLINE instead of MEM_GOING_OFFLINE/ONLINE
> 
> Balbir Singh (3):
>   mm: Add basic infrastructure for memcg hotplug support
>   mm: Move operations to hotplug callbacks
>   powerpc/mm: fix node_possible_map limitations
> 
>  arch/powerpc/mm/numa.c |   7 ----
>  mm/memcontrol.c        | 107 +++++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 94 insertions(+), 20 deletions(-)
> 
> -- 
> 2.5.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id ACFA16B02E6
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:45:14 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so122567796pgd.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:14 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 26si28689347pfo.279.2016.11.15.15.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:45:13 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id i88so8635792pfk.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:45:13 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RESEND][v1 0/3] Support memory cgroup hotplug
Date: Wed, 16 Nov 2016 10:44:58 +1100
Message-Id: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

In the absence of hotplug we use extra memory proportional to
(possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
to disable large consumption with large number of cgroups. This patch
adds hotplug support to memory cgroups and reverts the commit that
limited possible nodes to online nodes.

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org> 
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

I've tested this patches under a VM with two nodes and movable
nodes enabled. I've offlined nodes and checked that the system
and cgroups with tasks deep in the hierarchy continue to work
fine.

Balbir Singh (3):
  Add basic infrastructure for memcg hotplug support
  Move from all possible nodes to online nodes
  powerpc: fix node_possible_map limitations

 arch/powerpc/mm/numa.c |  7 ----
 mm/memcontrol.c        | 96 +++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 83 insertions(+), 20 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

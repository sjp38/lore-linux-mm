Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7806B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:44:18 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id rf5so101216721pab.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:44:18 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id h26si24109447pfh.56.2016.11.14.15.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:44:17 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 3so10104911pgd.0
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:44:17 -0800 (PST)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [v1 0/3] Support memory cgroup hotplug
Date: Tue, 15 Nov 2016 10:44:02 +1100
Message-Id: <1479167045-28136-1-git-send-email-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, akpm@linux-foundation.org, tj@kernel.org, Balbir Singh <bsingharora@gmail.com>

In the absence of hotplug we use extra memory proportional to
(possible_nodes - online_nodes) * number_of_cgroups. PPC64 has a patch
to disable large consumption with large number of cgroups. This patch
adds hotplug support to memory cgroups and reverts the commit that
limited possible nodes to online nodes.

Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

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

Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6381C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:53:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1149218DE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:53:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1149218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367048E0019; Tue, 12 Feb 2019 04:53:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31B5D8E0017; Tue, 12 Feb 2019 04:53:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207678E0019; Tue, 12 Feb 2019 04:53:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB5ED8E0017
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:53:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id w51so1939747edw.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:53:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=g0Xnfni1nNLyqqMZYXWTGGae7dfySvPUxOC1YigUua0=;
        b=cTKmcXkSbWa5Tjtwskgj8wRFT16LcysIDdlcHR3hATXvGaekFWoKS3P8+ysKpzgpAW
         +LWEUBy3ASLC4GF+EFZhf+6oVV9G/8e04sHGwNubIX39mHATwn8xVbBDtOayBq7Nz9Mf
         YPOZ58KC/r9gV0q6F5NkbZzf0suUyoYwkGdEn1QIinb03UgGGsdfiFasWk3LcIZLQVrI
         S+PawmTe2qxVKQfriJNZkrVnkxyzFrgTHNb24rbb6IoVWZiOHu/SwXzHoe0r7O+va81H
         ekVWw/P3hVxA9UYn5Nxyr8AnNEVYk7h/YlVuP+DyLHzMT6nvy6zE3vfruJ4RSlpOQCi8
         zG8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaQjma4krQxbWDZCqt+kD50GG//dtZlrnMyinF4qTvFJk6hA6hy
	u0z2zOvFG4G8olHxIFkSK3rqGPHFWdy8qB+9MPyINg9xKbMGTspQVEvxJXhB+Nsxeu/erE6Z+sE
	PrBZE0tyZLOiXvMmhTUmArAnpW4eXmgP7cOfb2Q6rCLzjcLLU4lWzupNq75HEN2HBjWh886Wnky
	Y75N/iUo6IC6Q8/cfjcel6oFCVs66gmAg7UN2jQjGCusl88M87UlFFWksHvYTOKJR47lhrZCiEl
	9gEQi01MdWy8kA00uLIIhX1ZGOBZ9M7DF0A1uja9Mz7zfLJhKVGh2u/uBCt96e4NyJjbwvCMcZH
	PYbOGYM2F3+v3QXxtQaHPjhPSvcxgeARw7s6wS3QqA3QaaVZuRC4fvPyVZ7RJAp1MNDhrC039A=
	=
X-Received: by 2002:a05:6402:1482:: with SMTP id e2mr2252334edv.59.1549965238285;
        Tue, 12 Feb 2019 01:53:58 -0800 (PST)
X-Received: by 2002:a05:6402:1482:: with SMTP id e2mr2252272edv.59.1549965236995;
        Tue, 12 Feb 2019 01:53:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549965236; cv=none;
        d=google.com; s=arc-20160816;
        b=x6sDXHhGmJthEVWChCYWiD0tBc+voPzk722CQLGK6fyjv0pIDjsWSOvzFeSzJi6z3h
         HM7dh6qk4E2IYvt7r8b8OUWdW5KNI1oSUxFYpsV74K0pI0OUCyv62+gWy7K6U6F/2TAN
         ZrUPFKQQUhkaqD8DX6s8Ok9ErE9SEXtl06A5L/wIRtNQwno3/ppO+n7+nX2O3rqCNa5G
         lH7pV+cG08WhhgWpmO1oqv/GXENrkW8jz5mtAiQKomLW0SIV9yFdZrcvzdZbZetNt5ye
         7Dvt0yGJjCpPvEAVE4YhO29BaaNLoL6zzWDOhf9E0NblIUz19SBoJikm/ZBelMOIL5k7
         tiKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=g0Xnfni1nNLyqqMZYXWTGGae7dfySvPUxOC1YigUua0=;
        b=dMV21kh8vfSTtLtiRkZsnfSkbtzmT1dWGQJRVGnQH9XY/xA+ez6jOaPa19MAN+IzqP
         jbyJ6qDnY9uZw95cfpaEUUXSdOeGsxaBfgFVQ2TkRx8NWOiXyk0A425NcnB+OtEsseix
         wc4vTecI8jDeb8lVJA+bmbkDIgEvP7cKFPTryodNu4cbXzwURHRY/Lk/bxOaPpKnDrwq
         DZsFSMx/YgyWP81usb3mqbFv+b27nEXRFkqAcLrqDpiozWvgEjWvyRuuZpD0jfqPpWYV
         u2sivHIijeeZ+RxekQVJcwnmgEa2ybw7Z54hZWdXWObxaWQ8G4qXWra3PbLXK1RKlXDA
         STuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m25sor3404908ejs.37.2019.02.12.01.53.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 01:53:56 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IYI+XQIdqqNKKXiwk3GZD4kvnkwSEFaqfDAQjdPPwJO5MpWchNSzvqMlUDOtjpHeFQrvetnVQ==
X-Received: by 2002:a17:906:3e95:: with SMTP id a21mr2097068ejj.44.1549965236193;
        Tue, 12 Feb 2019 01:53:56 -0800 (PST)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id i14sm2876791ejy.25.2019.02.12.01.53.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 01:53:55 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/2] x86, numa: always initialize all possible nodes
Date: Tue, 12 Feb 2019 10:53:42 +0100
Message-Id: <20190212095343.23315-2-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212095343.23315-1-mhocko@kernel.org>
References: <20190212095343.23315-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

Pingfan Liu has reported the following splat
[    5.772742] BUG: unable to handle kernel paging request at 0000000000002088
[    5.773618] PGD 0 P4D 0
[    5.773618] Oops: 0000 [#1] SMP NOPTI
[    5.773618] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.20.0-rc1+ #3
[    5.773618] Hardware name: Dell Inc. PowerEdge R7425/02MJ3T, BIOS 1.4.3 06/29/2018
[    5.773618] RIP: 0010:__alloc_pages_nodemask+0xe2/0x2a0
[    5.773618] Code: 00 00 44 89 ea 80 ca 80 41 83 f8 01 44 0f 44 ea 89 da c1 ea 08 83 e2 01 88 54 24 20 48 8b 54 24 08 48 85 d2 0f 85 46 01 00 00 <3b> 77 08 0f 82 3d 01 00 00 48 89 f8 44 89 ea 48 89
e1 44 89 e6 89
[    5.773618] RSP: 0018:ffffaa600005fb20 EFLAGS: 00010246
[    5.773618] RAX: 0000000000000000 RBX: 00000000006012c0 RCX: 0000000000000000
[    5.773618] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000002080
[    5.773618] RBP: 00000000006012c0 R08: 0000000000000000 R09: 0000000000000002
[    5.773618] R10: 00000000006080c0 R11: 0000000000000002 R12: 0000000000000000
[    5.773618] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000002
[    5.773618] FS:  0000000000000000(0000) GS:ffff8c69afe00000(0000) knlGS:0000000000000000
[    5.773618] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    5.773618] CR2: 0000000000002088 CR3: 000000087e00a000 CR4: 00000000003406e0
[    5.773618] Call Trace:
[    5.773618]  new_slab+0xa9/0x570
[    5.773618]  ___slab_alloc+0x375/0x540
[    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  __slab_alloc+0x1c/0x38
[    5.773618]  __kmalloc_node_track_caller+0xc8/0x270
[    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  devm_kmalloc+0x28/0x60
[    5.773618]  pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  really_probe+0x73/0x420
[    5.773618]  driver_probe_device+0x115/0x130
[    5.773618]  __driver_attach+0x103/0x110
[    5.773618]  ? driver_probe_device+0x130/0x130
[    5.773618]  bus_for_each_dev+0x67/0xc0
[    5.773618]  ? klist_add_tail+0x3b/0x70
[    5.773618]  bus_add_driver+0x41/0x260
[    5.773618]  ? pcie_port_setup+0x4d/0x4d
[    5.773618]  driver_register+0x5b/0xe0
[    5.773618]  ? pcie_port_setup+0x4d/0x4d
[    5.773618]  do_one_initcall+0x4e/0x1d4
[    5.773618]  ? init_setup+0x25/0x28
[    5.773618]  kernel_init_freeable+0x1c1/0x26e
[    5.773618]  ? loglevel+0x5b/0x5b
[    5.773618]  ? rest_init+0xb0/0xb0
[    5.773618]  kernel_init+0xa/0x110
[    5.773618]  ret_from_fork+0x22/0x40
[    5.773618] Modules linked in:
[    5.773618] CR2: 0000000000002088
[    5.773618] ---[ end trace 1030c9120a03d081 ]---

with his AMD machine with the following topology
  NUMA node0 CPU(s):     0,8,16,24
  NUMA node1 CPU(s):     2,10,18,26
  NUMA node2 CPU(s):     4,12,20,28
  NUMA node3 CPU(s):     6,14,22,30
  NUMA node4 CPU(s):     1,9,17,25
  NUMA node5 CPU(s):     3,11,19,27
  NUMA node6 CPU(s):     5,13,21,29
  NUMA node7 CPU(s):     7,15,23,31

[    0.007418] Early memory node ranges
[    0.007419]   node   1: [mem 0x0000000000001000-0x000000000008efff]
[    0.007420]   node   1: [mem 0x0000000000090000-0x000000000009ffff]
[    0.007422]   node   1: [mem 0x0000000000100000-0x000000005c3d6fff]
[    0.007422]   node   1: [mem 0x00000000643df000-0x0000000068ff7fff]
[    0.007423]   node   1: [mem 0x000000006c528000-0x000000006fffffff]
[    0.007424]   node   1: [mem 0x0000000100000000-0x000000047fffffff]
[    0.007425]   node   5: [mem 0x0000000480000000-0x000000087effffff]

and nr_cpus set to 4. The underlying reason is tha the device is bound
to node 2 which doesn't have any memory and init_cpu_to_node only
initializes memory-less nodes for possible cpus which nr_cpus restrics.
This in turn means that proper zonelists are not allocated and the page
allocator blows up.

Fix the issue by reworking how x86 initializes the memory less nodes.
The current implementation is hacked into the workflow and it doesn't
allow any flexibility. There is init_memory_less_node called for each
offline node that has a CPU as already mentioned above. This will make
sure that we will have a new online node without any memory. Much later
on we build a zone list for this node and things seem to work, except
they do not (e.g. due to nr_cpus). Not to mention that it doesn't really
make much sense to consider an empty node as online because we just
consider this node whenever we want to iterate nodes to use and empty
node is obviously not the best candidate. This is all just too fragile.

The new code relies on the arch specific initialization to allocate all
possible NUMA nodes (including memory less) - numa_register_memblks in
this case. Generic code then initializes both zonelists (__build_all_zonelists)
and allocator internals (free_area_init_nodes) for all non-null pgdats
rather than online ones.

For the x86 specific part also do not make new node online in alloc_node_data
because this is too early to know that. numa_register_memblks knows that
a node has some memory so it can make the node online appropriately.
init_memory_less_node hack can be safely removed altogether now.

Reported-by: Pingfan Liu <kernelfans@gmail.com>
Tested-by: Pingfan Liu <kernelfans@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/mm/numa.c | 27 +++------------------------
 mm/page_alloc.c    | 15 +++++++++------
 2 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1308f5408bf7..b3621ee4dfe8 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -216,8 +216,6 @@ static void __init alloc_node_data(int nid)
 
 	node_data[nid] = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
-
-	node_set_online(nid);
 }
 
 /**
@@ -570,7 +568,7 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 		return -EINVAL;
 
 	/* Finally register nodes. */
-	for_each_node_mask(nid, node_possible_map) {
+	for_each_node_mask(nid, numa_nodes_parsed) {
 		u64 start = PFN_PHYS(max_pfn);
 		u64 end = 0;
 
@@ -581,9 +579,6 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			end = max(mi->blk[i].end, end);
 		}
 
-		if (start >= end)
-			continue;
-
 		/*
 		 * Don't confuse VM with a node that doesn't have the
 		 * minimum amount of memory:
@@ -592,6 +587,8 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 			continue;
 
 		alloc_node_data(nid);
+		if (end)
+			node_set_online(nid);
 	}
 
 	/* Dump memblock with node info and return. */
@@ -721,21 +718,6 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static void __init init_memory_less_node(int nid)
-{
-	unsigned long zones_size[MAX_NR_ZONES] = {0};
-	unsigned long zholes_size[MAX_NR_ZONES] = {0};
-
-	/* Allocate and initialize node data. Memory-less node is now online.*/
-	alloc_node_data(nid);
-	free_area_init_node(nid, zones_size, 0, zholes_size);
-
-	/*
-	 * All zonelists will be built later in start_kernel() after per cpu
-	 * areas are initialized.
-	 */
-}
-
 /*
  * Setup early cpu_to_node.
  *
@@ -763,9 +745,6 @@ void __init init_cpu_to_node(void)
 		if (node == NUMA_NO_NODE)
 			continue;
 
-		if (!node_online(node))
-			init_memory_less_node(node);
-
 		numa_set_node(cpu, node);
 	}
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..2e097f336126 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5361,10 +5361,11 @@ static void __build_all_zonelists(void *data)
 	if (self && !node_online(self->node_id)) {
 		build_zonelists(self);
 	} else {
-		for_each_online_node(nid) {
+		for_each_node(nid) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 
-			build_zonelists(pgdat);
+			if (pgdat)
+				build_zonelists(pgdat);
 		}
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
@@ -6644,10 +6645,8 @@ static unsigned long __init find_min_pfn_for_node(int nid)
 	for_each_mem_pfn_range(i, nid, &start_pfn, NULL, NULL)
 		min_pfn = min(min_pfn, start_pfn);
 
-	if (min_pfn == ULONG_MAX) {
-		pr_warn("Could not find start_pfn for node %d\n", nid);
+	if (min_pfn == ULONG_MAX)
 		return 0;
-	}
 
 	return min_pfn;
 }
@@ -6991,8 +6990,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	mminit_verify_pageflags_layout();
 	setup_nr_node_ids();
 	zero_resv_unavail();
-	for_each_online_node(nid) {
+	for_each_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
+
+		if (!pgdat)
+			continue;
+
 		free_area_init_node(nid, NULL,
 				find_min_pfn_for_node(nid), NULL);
 
-- 
2.20.1


Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 182D96B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:46:57 -0400 (EDT)
Received: by igcur8 with SMTP id ur8so40280389igc.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:46:56 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id x6si7700859igl.33.2015.06.29.08.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 08:46:56 -0700 (PDT)
Received: by igrv9 with SMTP id v9so31895246igr.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:46:56 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Return proper error code return if call to kzalloc_node falis in the function alloc_mem_cgroup_per_zone_info
Date: Mon, 29 Jun 2015 11:46:53 -0400
Message-Id: <1435592813-24499-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This changes us returning the value of one to -ENOMEM when the call
for allocating memory with the function kzalloc_node fails in order
to better comply with kernel coding pratices of returning this
particular error code when memory allocations that are unrecoverable
occur.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index acb93c5..4e80811 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4442,7 +4442,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 		tmp = -1;
 	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
 	if (!pn)
-		return 1;
+		return -ENOMEM;
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

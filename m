Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10E1F6B000C
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 04:13:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 90-v6so922565pla.18
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 01:13:34 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0098.outbound.protection.outlook.com. [104.47.1.98])
        by mx.google.com with ESMTPS id t10-v6si442249pgn.370.2018.08.02.01.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Aug 2018 01:13:32 -0700 (PDT)
Subject: [PATCH] memcg: Add comment to mem_cgroup_css_online()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
 <20180413125101.GO17484@dhcp22.suse.cz>
 <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
 <20180727193134.GA10996@cmpxchg.org>
 <20180729192621.py4znecoinw5mqcp@esperanza>
 <20180730153113.GB4567@cmpxchg.org>
 <20180731163908.603d7a27c6534341e1afa724@linux-foundation.org>
 <20180801155552.GA8600@cmpxchg.org>
 <20180801162235.j3v7xipyw5afnj4x@esperanza>
 <7a836e47-f0a4-6802-9b90-cc473e5ab90b@virtuozzo.com>
Message-ID: <521f9e5f-c436-b388-fe83-4dc870bfb489@virtuozzo.com>
Date: Thu, 2 Aug 2018 11:13:24 +0300
MIME-Version: 1.0
In-Reply-To: <7a836e47-f0a4-6802-9b90-cc473e5ab90b@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Explain relationships between allocation and expanding.

Suggested-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d90993ef1d7d..34e5ff72ce87 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4703,6 +4703,11 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	/*
+	 * A memcg must be visible for memcg_expand_shrinker_maps()
+	 * by the time the maps are allocated. So, we allocate maps
+	 * here, when for_each_mem_cgroup() can't skip it.
+	 */
 	if (memcg_alloc_shrinker_maps(memcg)) {
 		mem_cgroup_id_remove(memcg);
 		return -ENOMEM;

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5A5116B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 14:04:46 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id fo12so799047lab.39
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 11:04:44 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v2 0/2] slightly rework memcg cache id determination
Date: Fri, 14 Jun 2013 14:04:34 -0400
Message-Id: <1371233076-936-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@openvz.org>

Michal,

Let me know if this is more acceptable to you. I didn't take your suggestion of
having an id and idx functions, because I think this could potentially be even
more confusing: in the sense that people would need to wonder a bit what is the
difference between them.

Note please that we never use the id as an array index outside of memcg core.
So for memcg core, I have changed, in Patch 2, each direct use of idx as an
index to include a VM_BUG_ON in case we would get an invalid index.

For the other cases, I have consolidated a bit the usage pattern around
memcg_cache_id.  Now the tests are all pretty standardized.

Glauber Costa (2):
  memcg: make cache index determination more robust
  memcg: consolidate callers of memcg_cache_id

 mm/memcontrol.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

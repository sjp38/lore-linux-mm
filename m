Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEBC56B0007
	for <linux-mm@kvack.org>; Thu,  3 May 2018 15:29:49 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id p75-v6so8902162ywe.22
        for <linux-mm@kvack.org>; Thu, 03 May 2018 12:29:49 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y123-v6sor3668175ywg.308.2018.05.03.12.29.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 12:29:47 -0700 (PDT)
MIME-Version: 1.0
Date: Thu,  3 May 2018 12:29:40 -0700
Message-Id: <20180503192940.94971-1-gthelen@google.com>
Subject: [PATCH] memcg: mark memcg1_events static const
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Mark memcg1_events static: it's only used by memcontrol.c.
And mark it const: it's not modified.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2bd3df3d101a..c9c7e5ea0e2f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3083,7 +3083,7 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 #endif /* CONFIG_NUMA */
 
 /* Universal VM events cgroup1 shows, original sort order */
-unsigned int memcg1_events[] = {
+static const unsigned int memcg1_events[] = {
 	PGPGIN,
 	PGPGOUT,
 	PGFAULT,
-- 
2.17.0.441.gb46fe60e1d-goog

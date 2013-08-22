Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 8CB156B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 01:40:06 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1320534pbc.4
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 22:40:05 -0700 (PDT)
Date: Thu, 22 Aug 2013 13:39:56 +0800
From: larmbr <nasa4836@gmail.com>
Subject: [PATCH] mm/vmscan: make global_reclaim() inline
Message-ID: <20130822053956.GA10795@larmbr-lcx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, riel@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Though Gcc is likely to inline them, we should better
explictly do it manually, and also, this serve to document 
this fact.

Signed-off-by: Zhan Jianyu <nasa4836@gmail.com>
---
mm/vmscan.c |    4 ++--
1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1de652d..1946d7d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -135,12 +135,12 @@ static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
 #ifdef CONFIG_MEMCG
-static bool global_reclaim(struct scan_control *sc)
+static inline bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
 }
 #else
-static bool global_reclaim(struct scan_control *sc)
+static inline bool global_reclaim(struct scan_control *sc)
 {
 	return true;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

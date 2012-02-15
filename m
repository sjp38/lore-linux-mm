Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B6CF76B007E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 14:27:13 -0500 (EST)
Received: by bkty12 with SMTP id y12so1694268bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 11:27:11 -0800 (PST)
Subject: [PATCH] memcg: kill dead prev_priority stubs
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 15 Feb 2012 23:27:08 +0400
Message-ID: <20120215192708.31690.2819.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

This code was removed in v2.6.35-5854-g25edde0
("vmscan: kill prev_priority completely")

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 453a3dd..c697eda 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -296,21 +296,6 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
-static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *memcg)
-{
-	return 0;
-}
-
-static inline void mem_cgroup_note_reclaim_priority(struct mem_cgroup *memcg,
-						int priority)
-{
-}
-
-static inline void mem_cgroup_record_reclaim_priority(struct mem_cgroup *memcg,
-						int priority)
-{
-}
-
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

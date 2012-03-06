Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 437B06B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 07:12:43 -0500 (EST)
Received: by iajr24 with SMTP id r24so9119027iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 04:12:42 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: revise the position of threshold index while unregistering event
Date: Tue,  6 Mar 2012 20:12:23 +0800
Message-Id: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Index current_threshold should point to threshold just below or equal to usage.
See below:
http://www.spinics.net/lists/cgroups/msg00844.html


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 22d94f5..cd40d67 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4398,7 +4398,7 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 			continue;
 
 		new->entries[j] = thresholds->primary->entries[i];
-		if (new->entries[j].threshold < usage) {
+		if (new->entries[j].threshold <= usage) {
 			/*
 			 * new->current_threshold will not be used
 			 * until rcu_assign_pointer(), so it's safe to increment
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

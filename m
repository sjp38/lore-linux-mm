Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 75F666B0032
	for <linux-mm@kvack.org>; Mon, 27 May 2013 11:38:49 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id er20so6482648lab.5
        for <linux-mm@kvack.org>; Mon, 27 May 2013 08:38:47 -0700 (PDT)
From: Sergey Dyasly <dserrg@gmail.com>
Subject: [PATCH][trivial] memcg: Kconfig info update
Date: Mon, 27 May 2013 19:36:24 +0400
Message-Id: <1369668984-2787-1-git-send-email-dserrg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Dyasly <dserrg@gmail.com>

Now there are only 2 members in struct page_cgroup.
Update config MEMCG description accordingly.

Signed-off-by: Sergey Dyasly <dserrg@gmail.com>
---
 init/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/init/Kconfig b/init/Kconfig
index 9d3a788..16d1502 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -876,7 +876,7 @@ config MEMCG
 
 	  Note that setting this option increases fixed memory overhead
 	  associated with each page of memory in the system. By this,
-	  20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
+	  8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
 	  usage tracking struct at boot. Total amount of this is printed out
 	  at boot.
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 069F76B0022
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:37:24 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH next 14/15] mm: Convert vmalloc/memset to vzalloc
Date: Sat, 28 May 2011 10:36:34 -0700
Message-Id: <f3d616b526e00bd8f01a250b7ce8c5a6e2412768.1306603968.git.joe@perches.com>
In-Reply-To: <cover.1306603968.git.joe@perches.com>
References: <cover.1306603968.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Jiri Kosina <trivial@kernel.org>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_cgroup.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 74ccff6..dbb28fd 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -478,11 +478,10 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
 	array_size = length * sizeof(void *);
 
-	array = vmalloc(array_size);
+	array = vzalloc(array_size);
 	if (!array)
 		goto nomem;
 
-	memset(array, 0, array_size);
 	ctrl = &swap_cgroup_ctrl[type];
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl->length = length;
-- 
1.7.5.rc3.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 21/24] cgroup: define empty css_put() when !CONFIG_CGROUPS
Date: Wed, 02 Dec 2009 11:12:52 +0800
Message-ID: <20091202043046.420815285@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D70396007BD
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:38 -0500 (EST)
Content-Disposition: inline; filename=memcg-css_put.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

It will be used by the hwpoison inject code for releasing the
css grabbed by try_get_mem_cgroup_from_page().

CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Li Zefan <lizf@cn.fujitsu.com>
CC: Paul Menage <menage@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/cgroup.h |    3 +++
 1 file changed, 3 insertions(+)

--- linux-mm.orig/include/linux/cgroup.h	2009-11-02 10:18:41.000000000 +0800
+++ linux-mm/include/linux/cgroup.h	2009-11-02 10:26:22.000000000 +0800
@@ -581,6 +581,9 @@ static inline int cgroupstats_build(stru
 	return -EINVAL;
 }
 
+struct cgroup_subsys_state;
+static inline void css_put(struct cgroup_subsys_state *css) {}
+
 #endif /* !CONFIG_CGROUPS */
 
 #endif /* _LINUX_CGROUP_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

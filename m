Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF619000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 21:15:28 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] mm/page_cgroup.c: quiet sparse noise
Date: Thu, 22 Sep 2011 18:15:08 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <201109221815.08891.hartleys@visionengravers.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, paul@paulmenage.org, lizf@cn.fujitsu.com, bsingharora@gmail.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com

Quite the sparse noise:

warning: symbol 'swap_cgroup_ctrl' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Paul Menage <paul@paulmenage.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 6bdc67d..eead840 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -357,7 +357,7 @@ struct swap_cgroup_ctrl {
 	spinlock_t	lock;
 };
 
-struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
+static struct swap_cgroup_ctrl swap_cgroup_ctrl[MAX_SWAPFILES];
 
 struct swap_cgroup {
 	unsigned short		id;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0B558D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 22:36:13 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 42so724778iyh.14
        for <linux-mm@kvack.org>; Mon, 11 Apr 2011 19:36:12 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH RESEND 4/4] MAINTAINERS: add mm/page_cgroup.c into memcg subsystem
Date: Tue, 12 Apr 2011 11:35:37 +0900
Message-Id: <1302575737-6401-4-git-send-email-namhyung@gmail.com>
In-Reply-To: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
References: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

AFAICS mm/page_cgroup.c is for memcg subsystem, but it was directed
only to generic cgroup maintainers. Fix it.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 649600cb8ec9..1a369aa9a578 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4121,6 +4121,7 @@ M:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
 L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/memcontrol.c
+F:	mm/page_cgroup.c
 
 MEMORY TECHNOLOGY DEVICES (MTD)
 M:	David Woodhouse <dwmw2@infradead.org>
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

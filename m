Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 141FF6B01D9
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 05:33:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o519XnFR032402
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Jun 2010 18:33:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 867D945DE52
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:33:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5741645DE4E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:33:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3103A1DB8037
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:33:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF64BE18004
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 18:33:48 +0900 (JST)
Date: Tue, 1 Jun 2010 18:29:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][3/3] memcg swap accounts remove experimental
Message-Id: <20100601182936.36ea72b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601182720.f1562de6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

It has benn a year since we changed swap_map[] to indicates SWAP_HAS_CACHE.
By that, memcg's swap accounting has been very stable and it seems
it can be maintained. 

So, I'd like to remove EXPERIMENTAL from the config.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 init/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mmotm-2.6.34-May21/init/Kconfig
===================================================================
--- mmotm-2.6.34-May21.orig/init/Kconfig
+++ mmotm-2.6.34-May21/init/Kconfig
@@ -577,8 +577,8 @@ config CGROUP_MEM_RES_CTLR
 	  could in turn add some fork/exit overhead.
 
 config CGROUP_MEM_RES_CTLR_SWAP
-	bool "Memory Resource Controller Swap Extension(EXPERIMENTAL)"
-	depends on CGROUP_MEM_RES_CTLR && SWAP && EXPERIMENTAL
+	bool "Memory Resource Controller Swap Extension"
+	depends on CGROUP_MEM_RES_CTLR && SWAP
 	help
 	  Add swap management feature to memory resource controller. When you
 	  enable this, you can limit mem+swap usage per cgroup. In other words,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

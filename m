Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CE5416B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:01:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBG9GWO1012480
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Dec 2008 18:16:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1735B45DE4E
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:16:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EC5A445DE4C
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:16:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D82901DB803A
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:16:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 903B51DB803F
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 18:16:31 +0900 (JST)
Date: Tue, 16 Dec 2008 18:15:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/9] Add css_is_remvoed
Message-Id: <20081216181535.c842dade.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081216180936.d6b65abf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I hear Paul Menage will add similar call to his set.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Adding a function for checking css is removed or not.
Maybe this patch will be unnecessary.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.28-Dec12/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.28-Dec12.orig/include/linux/cgroup.h
+++ mmotm-2.6.28-Dec12/include/linux/cgroup.h
@@ -110,6 +110,11 @@ static inline void css_put(struct cgroup
 		__css_put(css);
 }
 
+static inline bool css_is_removed(struct cgroup_subsys_state *css)
+{
+	return test_bit(CSS_REMOVED, &css->flags);
+}
+
 /* bits in struct cgroup flags field */
 enum {
 	/* Control Group is dead */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

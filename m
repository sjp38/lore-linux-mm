Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C82C86B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:02:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C12Znh023297
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 10:02:35 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A1645DD7D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:02:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1069545DD7B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:02:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE9E41DB8042
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:02:34 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44E491DB8045
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:02:34 +0900 (JST)
Date: Thu, 12 Mar 2009 10:01:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 6/5] softlimit document
Message-Id: <20090312100112.6f010cae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Sorry...6th patch.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Documentation for softlimit

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/memory.txt |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

Index: mmotm-2.6.29-Mar10/Documentation/cgroups/memory.txt
===================================================================
--- mmotm-2.6.29-Mar10.orig/Documentation/cgroups/memory.txt
+++ mmotm-2.6.29-Mar10/Documentation/cgroups/memory.txt
@@ -322,6 +322,25 @@ will be charged as a new owner of it.
   - a cgroup which uses hierarchy and it has child cgroup.
   - a cgroup which uses hierarchy and not the root of hierarchy.
 
+5.4 softlimit
+  Memory cgroup supports softlimit and has 2 params for control.
+    - memory.softlimit_in_bytes
+	- softlimit to this cgroup.
+    - memory.softlimit_priority.
+	- priority of this cgroup at softlimit reclaim.
+	  Allowed priority level is 3-0 and 3 is the lowest.
+	  If 0, this cgroup will not be target of softlimit.
+
+  At memory shortage of the system (or local node/zone), softlimit helps
+  kswapd(), a global memory recalim kernel thread, and inform victim cgroup
+  to be shrinked to kswapd.
+
+  Victim selection logic:
+  The kernel searches from the lowest priroty(3) up to the highest(1).
+  If it find a cgroup witch has memory larger than softlimit, steal memory
+  from it.
+  If multiple cgroups are on the same priority, each cgroup wil be a
+  victim in turn.
 
 6. Hierarchy support
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

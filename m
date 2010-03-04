Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 67D666B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 00:54:08 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o245s5dl004613
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Mar 2010 14:54:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1419245DE51
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:54:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCF4B45DE55
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A33F11DB803C
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:54:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 56FD4E38003
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 14:54:04 +0900 (JST)
Date: Thu, 4 Mar 2010 14:50:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: update mainteiner list
Message-Id: <20100304145030.22a35a7e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, balbir@linux.vnet.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Updates for maintainer list of memcg.
I'd like to add Nishimura-san to maintainer of memcg, he works really well.
And I'm sorry that I've not seen Pavel on memcg discussion for a year.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Nishimura-san have been working for memcg very good.
His review and tests give us much improvements and account migraiton
which he is now challenging is really important.

He is a stakeholder.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 MAINTAINERS |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-2.6.33-Mar2/MAINTAINERS
===================================================================
--- mmotm-2.6.33-Mar2.orig/MAINTAINERS
+++ mmotm-2.6.33-Mar2/MAINTAINERS
@@ -3675,7 +3675,7 @@ F:	mm/
 
 MEMORY RESOURCE CONTROLLER
 M:	Balbir Singh <balbir@linux.vnet.ibm.com>
-M:	Pavel Emelyanov <xemul@openvz.org>
+M:	Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
 M:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
 L:	linux-mm@kvack.org
 S:	Maintained

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

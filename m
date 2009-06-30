Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DAFCE6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:02:42 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5U92hGh012964
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Jun 2009 18:02:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F7A845DE79
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:02:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1600245DE70
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:02:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF9981DB8040
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:02:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B0B0F1DB8042
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:02:42 +0900 (JST)
Date: Tue, 30 Jun 2009 18:01:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg: fix cgroup rmdir hang v3
Message-Id: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Updated from previous one.

 - Updated comments.
 - add cgroup_exclude_rmdir()/cgroup_release_rmdir().

Patch 1/2 is tested by Nishimura (look is modified but the same algorithm..)
Patch 2/2 is a new. but no difficulty.

Thank you for all your helps

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

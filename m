Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 29F086B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 01:03:39 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 46EC43EE0B6
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:03:34 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E95C45DE58
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:03:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 194B345DE54
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:03:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C4081DB8040
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:03:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CBDA21DB803B
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:03:33 +0900 (JST)
Date: Tue, 25 Jan 2011 14:57:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/3] 3 bugfixes for memory cgroup (2.6.38-rc2)
Message-Id: <20110125145720.cd0cbe16.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



Hi, these are 3 bugfix patches for 2.6.38-rc2 + 
 mm-memcontrolc-fix-uninitialized-variable-use-in-mem_cgroup_move_parent.patch
in mm tree.

3 patches are independent from each other but [1/3] patch is for
2.6.36-stable, tree.

[1/3] fix account leak at failure of memsw acconting. (for 2.6.36 stable)
[2/3] check mem_cgroup_disabled() at split fixup (for recent 2.6.38-git)
[3/3] fix race at move_parent() (This depends on m-memcontrolc
      fix-uninitialized-variable-use-in-mem_cgroup_move_parent.patch)

I'll send other fixes for THP/memcg but this is an early cut for obvious bugs.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

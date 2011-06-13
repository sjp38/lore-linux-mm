Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C04336B004A
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 23:08:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 40E5F3EE0AE
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:08:16 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 19E3E45DE87
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:08:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EFCD545DE67
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:08:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD4151DB803B
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:08:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F1611DB803F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:08:15 +0900 (JST)
Date: Mon, 13 Jun 2011 12:00:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 0/5] memcg bugfixes in the last week.
Message-Id: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>


In the last week, I(and memcg people) posted 5 bug fixes.
I was slightly confued. 

For making things clearer, I post all 5 patches again,
which are I'm now testing. 

If I miss some patches/fixes/bugs, please notify me. 

[1/5] - fix memory.numa_stat permission (this is in mmotm)
[2/5] - fix init_page_cgroup() nid with sparsemem
[3/5] - fix mm->owner update
[4/5] - fix wrong check of noswap with softlimit
[5/5] - fix percpu cached charge draining.


Thank you for all your helps. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

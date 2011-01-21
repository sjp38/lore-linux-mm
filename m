Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B1CA8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:40:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EA7403EE0AE
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:40:31 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D13F045DE59
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:40:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6FF845DE55
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:40:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8C11E18004
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:40:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 720FE1DB803B
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:40:31 +0900 (JST)
Date: Fri, 21 Jan 2011 15:34:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/7] memcg : more fixes and clean up for 2.6.28-rc
Message-Id: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


This is a set of patches which I'm now testing, and it seems it passed
small test. So I post this.

Some are bug fixes and other are clean ups but I think these are for 2.6.38.

Brief decription

[1/7] remove buggy comment and use better name for mem_cgroup_move_parent()
      The fixes for mem_cgroup_move_parent() is already in mainline, this is
      an add-on.

[2/7] a bug fix for a new function mem_cgroup_split_huge_fixup(),
      which was recently merged.

[3/7] prepare for fixes in [4/7],[5/7]. This is an enhancement of function
      which is used now.

[4/7] fix mem_cgroup_charge() for THP. By this, memory cgroup's charge function
      will handle THP request in sane way.

[5/7] fix khugepaged scan condition for memcg.
      This is a fix for hang of processes under small/buzy memory cgroup.

[6/7] rename vairable names to be page_size, nr_pages, bytes rather than
      ambiguous names.

[7/7] some memcg function requires the caller to initialize variable
      before call. It's ugly and fix it.


I think patch 1,2,3,4,5 is urgent ones. But I think patch "5" needs some
good review. But without "5", stress-test on small memory cgroup will not
run succesfully.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

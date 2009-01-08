Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 513556B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 05:12:10 -0500 (EST)
Date: Thu, 8 Jan 2009 19:08:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 0/4] some memcg fixes
Message-Id: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi.

These are patches that I've been testing.

They survived my test(rmdir aftre task move under memory pressure
and page migration) w/o big problem(except oom) for hours
in both use_hierarchy==0/1 case.

I want them go in 2.6.29.

They are based on mmotm-2009-01-05-12-50.

[1/4] fix for mem_cgroup_get_reclaim_stat_from_page

[2/4] fix error path of mem_cgroup_move_parent

[3/4] fix for mem_cgroup_hierarchical_reclaim

[4/4] make oom less frequently


I think 1 and 2 are ok.
I'll update them based on comments.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 176338D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 05:43:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 34C563EE0C2
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:43:34 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F082945DE6B
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:43:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D803A45DE68
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:43:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C906E1DB8042
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:43:33 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7687B1DB803B
	for <linux-mm@kvack.org>; Fri, 11 May 2012 18:43:33 +0900 (JST)
Message-ID: <4FACDED0.3020400@jp.fujitsu.com>
Date: Fri, 11 May 2012 18:41:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v3][0/6] memcg: prevent -ENOMEM in pre_destroy()
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

Hi, here is v3 based on memcg-devel tree.
git://github.com/mstsxfx/memcg-devel.git

This patch series is for avoiding -ENOMEM at calling pre_destroy() 
which is called at rmdir(). After this patch, charges will be moved
to root (if use_hierarchy==0) or parent (if use_hierarchy==1), and
we'll not see -ENOMEM in rmdir() of cgroup.

v2 included some other patches than ones for handling -ENOMEM problem,
but I divided it. I'd like to post others in different series, later.
No logical changes in general, maybe v3 is cleaner than v2.

0001 ....fix error code in memcg-hugetlb
0002 ....add res_counter_uncharge_until
0003 ....use res_counter_uncharge_until in memcg
0004 ....move charges to root is use_hierarchy==0
0005 ....cleanup for mem_cgroup_move_account()
0006 ....remove warning of res_counter_uncharge_nofail (from Costa's slub accounting series).

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

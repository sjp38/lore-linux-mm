Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1600D900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 13:29:29 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p7AHTMuk011702
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 22:59:22 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7AHTKrt3973374
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 22:59:22 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7AHTJDM030676
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 03:29:19 +1000
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Wed, 10 Aug 2011 22:59:17 +0530
Message-Id: <20110810172917.23280.9440.sendpatchset@oc5400248562.ibm.com>
Subject: [PATCH 0/2][cleanup] memcg: renaming of mem variable to memcg
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Hi,
 This is the memcg cleanup patch for that was talked little ago to change the  "struct
 mem_cgroup *mem" variable to  "struct mem_cgroup *memcg".

 The patch is though trivial, it is huge one.
 Testing : Compile tested with following configurations.
 1) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
 2) CONFIG_CGROUP_MEM_RES_CTLR=y  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
 3) CONFIG_CGROUP_MEM_RES_CTLR=n  CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n

 Also tested basic mounting with memcgroup.
 Raghu.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

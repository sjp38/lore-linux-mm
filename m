Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QIpjtx022987
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 14:51:45 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QIrFtI070990
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QIrECg001710
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:15 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 00:19:54 +0530
Message-Id: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
Subject: [RFC][0/3] Virtual address space control for cgroups (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is the second version of the virtual address space control patchset
for cgroups.  The patches are against 2.6.25-rc5-mm1 and have been tested on
top of User Mode Linux, both with and without the config enabled.

The first patch adds the user interface. The second patch adds accounting
and control. The third patch updates documentation.

The changelog in each patchset documents what has changed in version 2.
The most important one being that virtual address space accounting is
now a config option.

Reviews, Comments?

series

memory-controller-virtual-address-space-control-user-interface
memory-controller-virtual-address-space-accounting-and-control
memory-controller-virtual-address-control-documentation



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

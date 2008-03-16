Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2GHV9eV019030
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 13:31:09 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2GHV95V215396
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2GHV8ZE008593
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:08 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Mar 2008 22:59:42 +0530
Message-Id: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
Subject: [RFC][0/3] Virtual address space control for cgroups
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is an early patchset for virtual address space control for cgroups.
The patches are against 2.6.25-rc5-mm1 and have been tested on top of
User Mode Linux.

The first patch adds the user interface. The second patch adds accounting
and control. The third patch updates documentation.

Review suggestions would be appreciated along the lines of

1. What is missing? Are all virtual address space expansion points covered?
2. Do we need to account and control address space at insert_special_mapping?
3. Address space accounting may contain duplications. Do we need to avoid it?

Comments?

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

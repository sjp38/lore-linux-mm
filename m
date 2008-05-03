Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m43Lbqk7003251
	for <linux-mm@kvack.org>; Sat, 3 May 2008 17:37:52 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m43LblYj207342
	for <linux-mm@kvack.org>; Sat, 3 May 2008 15:37:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m43LbkRp023746
	for <linux-mm@kvack.org>; Sat, 3 May 2008 15:37:47 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 04 May 2008 03:07:26 +0530
Message-Id: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 0/4] Add rlimit controller to cgroups (v3)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is the third version of the address space control patches. These
patches are against 2.6.25-mm1  and have been tested using KVM in SMP mode,
both with and without the config enabled.

The first patch adds the user interface. The second patch fixes the
cgroup mm_owner_changed callback to pass the task struct, so that
accounting can be adjusted on owner changes. The thrid patch adds accounting
and control. The fourth patch updates documentation.

An earlier post of the patchset can be found at
http://lwn.net/Articles/275143/

This patch is built on top of the mm owner patches and utilizes that feature
to virtually group tasks by mm_struct.

Reviews, Comments?

Series

rlimit-controller-setup.patch
cgroup-add-task-to-mm--owner-callbacks.patch
rlimit-controller-address-space-accounting.patch
rlimit-controller-add-documentation.patch

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

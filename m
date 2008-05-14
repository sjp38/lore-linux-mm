Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4ED9OUJ022685
	for <linux-mm@kvack.org>; Wed, 14 May 2008 09:09:24 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4ED9Nll054110
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:09:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4ED9Mvg008073
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:09:23 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 14 May 2008 18:39:04 +0530
Message-Id: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 0/4] Add memrlimit controller (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is the fourth version of the address space control patches. These
patches are against 2.6.26-rc2-mm1  and have been tested using KVM in SMP mode,
both with and without the config enabled, on a powerpc box and using UML.
The patches have also been compile tested with the config disabled on a
powerpc box.

The goal of this patch is to implement a virtual address space controller
using cgroups. The documentation describes the controller, it's goal and
usage in further details.

The first patch adds the user interface. The second patch fixes the
cgroup mm_owner_changed callback to pass the task struct, so that
accounting can be adjusted on owner changes. The thrid patch adds accounting
and control. The fourth patch updates documentation.

An earlier post of the patchset can be found at
http://lwn.net/Articles/275143/

This patch is built on top of the mm owner patches and utilizes that feature
to virtually group tasks by mm_struct.

Reviews, Comments?

Changelog

1. Add documentation upfront
2. Refactor the code (error handling and changes to improvde code)
3. Protect reading of total_vm with mmap_sem
4. Port to 2.6.26-rc2
5. Changed the name from rlimit to memrlimit

Series

memrlimit-controller-add-documentation.patch
memrlimit-controller-setup.patch
cgroup-add-task-to-mm-owner-callbacks.patch
memrlimit-controller-address-space-accounting-and-control.patch

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

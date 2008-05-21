Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4LFUdeA014717
	for <linux-mm@kvack.org>; Wed, 21 May 2008 11:30:39 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4LFUQdm139540
	for <linux-mm@kvack.org>; Wed, 21 May 2008 09:30:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4LFUMWK015031
	for <linux-mm@kvack.org>; Wed, 21 May 2008 09:30:25 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 21 May 2008 20:59:21 +0530
Message-Id: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 0/4] Add memrlimit controller (v5)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is the fifth version of the address space control patches. These
patches are against 2.6.26-rc2-mm1  and have been tested using KVM in SMP mode,
both on a powerpc box

The goal of this patch is to implement a virtual address space controller
using cgroups. The documentation describes the controller, it's goal and
usage in further details.

Reviews, Comments?

Changelog

Patches [1/4] and [2/4] are unchanged
Patch [3/4] and [4/4] now formally use mmap_sem to protect mm->owner races.

Previous version of this patchset can be found at
http://lwn.net/Articles/282237/

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 33E3E6B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 16:37:10 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 11 Feb 2012 03:07:07 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1ALb1P34575346
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 03:07:02 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1ALb1tw001292
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 08:37:01 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/6] hugetlbfs: Add cgroup resource controller for hugetlbfs
Date: Sat, 11 Feb 2012 03:06:40 +0530
Message-Id: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aneesh.kumar@linux.vnet.ibm.com

Hi,

This patchset implements a cgroup resource controller for HugeTLB pages.
It is similar to the existing hugetlb quota support in that the limit is
enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
number of huge pages that can be allocated per superblock.

For shared mapping we track the region mapped by a task along with the
hugetlb cgroup in inode region list. We keep the hugetlb cgroup charged
even after the task that did mmap(2) exit. The uncharge happens during
file truncate. For Private mapping we charge and uncharge from the current
task cgroup.

The current patchset doesn't support cgroup hierarchy. We also don't
allow task migration across cgroup.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

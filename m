Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5409D6B0087
	for <linux-mm@kvack.org>; Fri, 31 Dec 2010 06:08:22 -0500 (EST)
Received: from mail06.corp.redhat.com (zmail06.collab.prod.int.phx2.redhat.com [10.5.5.45])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id oBVB8LBj025942
	for <linux-mm@kvack.org>; Fri, 31 Dec 2010 06:08:21 -0500
Date: Fri, 31 Dec 2010 06:08:21 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <617041603.101416.1293793701124.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1060163918.101411.1293793346203.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Problem: nr_overcommit_hugepages for 1gb hugepage went crazy.

Symptom:
1) setup 1gb hugepages.
# cat /proc/cmdline
default_hugepagesz=1g hugepagesz=1g hugepages=1
# cat /proc/meminfo
...
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
...

2) set nr_overcommit_hugepages
# echo 1 >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
# cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
1

3) overcommit 2gb hugepages.
mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED, 3, 0) = -1 ENOMEM (Cannot allocate memory)
# cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
18446744071589420672

As you can see from the above, it did not allow overcommit despite nr_overcommit_hugepages value. Also, nr_overcommit_hugepages was overwritten with such a strange value after overcommit failure. Should we just remove this file from sysfs for simplicity?

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

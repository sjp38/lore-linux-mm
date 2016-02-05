Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8766D4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 02:51:53 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id x4so45743797lbm.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 23:51:53 -0800 (PST)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id kk6si9091600lbc.76.2016.02.04.23.51.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 23:51:52 -0800 (PST)
Message-ID: <56B45457.4010702@huawei.com>
Date: Fri, 5 Feb 2016 15:50:47 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] why the amount of cache from "free -m" and /proc/meminfo are
 different?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

[root@localhost ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:          48295         574       41658           8        6062       46344
Swap:         24191           0       24191

[root@localhost ~]# cat /proc/meminfo
MemTotal:       49454896 kB
MemFree:        42658360 kB
MemAvailable:   47456052 kB
Buffers:               0 kB
Cached:          3727824 kB
SwapCached:            0 kB
Active:          2010196 kB
Inactive:        1784204 kB
Active(anon):      66612 kB
Inactive(anon):     8948 kB
Active(file):    1943584 kB
Inactive(file):  1775256 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      24772604 kB
SwapFree:       24772604 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         66672 kB
Mapped:            38440 kB
Shmem:              8984 kB
Slab:            2480092 kB
SReclaimable:    1291500 kB
SUnreclaim:      1188592 kB
KernelStack:        4480 kB
PageTables:         4928 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    49500052 kB
Committed_AS:     254220 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:     18432 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      140864 kB
DirectMap2M:     5093376 kB
DirectMap1G:    47185920 kB

[root@localhost ~]# uname -a
Linux localhost.localdomain 4.5.0-rc1-0.1-default+ #4 SMP Sat Jan 30 05:38:10 EST 2016 x86_64 x86_64 x86_64 GNU/Linux

[root@localhost ~]# rpm -qa | grep procps
procps-ng-3.3.10-3.el7.x86_64

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

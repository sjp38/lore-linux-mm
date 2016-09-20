Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32EFB6B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:46:20 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 92so20581552iom.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 19:46:20 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h58si22526992otd.125.2016.09.19.19.46.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 19:46:19 -0700 (PDT)
Message-ID: <57E0A2EC.7050809@huawei.com>
Date: Tue, 20 Sep 2016 10:46:04 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [question] hugetlb: how to find who use hugetlb?
References: <57DF4FEA.9080509@huawei.com>
In-Reply-To: <57DF4FEA.9080509@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/9/19 10:39, Xishi Qiu wrote:

> On my system, I set HugePages_Total to 2G(1024 x 2M), and I use 1G hugetlb,
> but the HugePages_Free is not 1G(512 x 2M), it is 280(280 x 2M) left,
> HugePages_Rsvd is 0, it seems someone use 232(232 x 2M) hugetlb additionally.
> 
> So how to find who use the additional hugetlb? 
> 
> I search every process and find the total hugetlb size is only 1G,
> cat /proc/xx/smaps | grep KernelPageSize, then account the vma size
> which KernelPageSize is 2048 kB.
> 
> Thanks,
> Xishi Qiu
> 

I kill the processes which use hugetlb, and set 0 to nr_hugepages.
My kernel version is v3.10

meminfo:
HugePages_Total:     232
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:      232
Hugepagesize:       2048 kB

"cat /proc/*/smaps | grep KernelPageSize| grep 2048" shows nothing.

linux-ZSfbIr:/home # mount | grep hugetlb
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime)
nodev on /dev/hugepages type hugetlbfs (rw,relatime)

linux-ZSfbIr:/home # ll /dev/hugepages/
total 0

linux-ZSfbIr:/home # ll /sys/fs/cgroup/hugetlb/
total 0
-rw-r--r-- 1 root root 0 Sep 13 08:10 cgroup.clone_children
--w--w--w- 1 root root 0 Sep 13 08:10 cgroup.event_control
-rw-r--r-- 1 root root 0 Sep 13 08:10 cgroup.procs
-r--r--r-- 1 root root 0 Sep 13 08:10 cgroup.sane_behavior
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.1GB.failcnt
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.1GB.limit_in_bytes
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.1GB.max_usage_in_bytes
-r--r--r-- 1 root root 0 Sep 13 08:10 hugetlb.1GB.usage_in_bytes
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.2MB.failcnt
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.2MB.limit_in_bytes
-rw-r--r-- 1 root root 0 Sep 13 08:10 hugetlb.2MB.max_usage_in_bytes
-r--r--r-- 1 root root 0 Sep 13 08:10 hugetlb.2MB.usage_in_bytes
-rw-r--r-- 1 root root 0 Sep 13 08:10 notify_on_release
-rw-r--r-- 1 root root 0 Sep 13 08:10 release_agent
-rw-r--r-- 1 root root 0 Sep 13 08:10 tasks
linux-ZSfbIr:/home #

> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

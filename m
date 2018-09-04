Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C64CB6B6F95
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 17:28:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l125-v6so2411283pga.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 14:28:28 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b124-v6si2488559pgc.620.2018.09.04.14.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 14:28:27 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Plumbers 2018 - Performance and Scalability Microconference
Message-ID: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
Date: Tue, 4 Sep 2018 17:28:13 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, daniel.m.jordan@oracle.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>brouer@redhat.com, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

Pavel Tatashin, Ying Huang, and I are excited to be organizing a performance and scalability microconference this year at Plumbers[*], which is happening in Vancouver this year.  The microconference is scheduled for the morning of the second day (Wed, Nov 14).

We have a preliminary agenda and a list of confirmed and interested attendees (cc'ed), and are seeking more of both!

Some of the items on the agenda as it stands now are:

  - Promoting huge page usage:  With memory sizes becoming ever larger, huge pages are becoming more and more important to reduce TLB misses and the overhead of memory management itself--that is, to make the system scalable with the memory size.  But there are still some remaining gaps that prevent huge pages from being deployed in some situations, such as huge page allocation latency and memory fragmentation.

  - Reducing the number of users of mmap_sem:  This semaphore is frequently used throughout the kernel.  In order to facilitate scaling this longstanding bottleneck, these uses should be documented and unnecessary users should be fixed.

  - Parallelizing cpu-intensive kernel work:  Resolve problems of past approaches including extra threads interfering with other processes, playing well with power management, and proper cgroup accounting for the extra threads.  Bonus topic: proper accounting of workqueue threads running on behalf of cgroups.

  - Preserving userland during kexec with a hibernation-like mechanism.

These center around our interests, but having lots of topics to choose from ensures we cover what's most important to the community, so we would like to hear about additional topics and extensions to those listed here.  This includes, but is certainly not limited to, work in progress that would benefit from in-person discussion, real-world performance problems, and experimental and academic work.

If you haven't already done so, please let us know if you are interested in attending, or have suggestions for other attendees.

Thanks,
Daniel

[*] https://blog.linuxplumbersconf.org/2018/performance-mc/

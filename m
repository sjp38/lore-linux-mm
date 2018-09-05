Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99E1A6B71BC
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 02:39:05 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so7435353oiw.13
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 23:39:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v76-v6si780542oif.114.2018.09.04.23.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 23:39:04 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w856ceY7040263
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 02:39:03 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ma89ac7hq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 02:39:03 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 07:39:00 +0100
Date: Wed, 5 Sep 2018 09:38:46 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
Message-Id: <20180905063845.GA23342@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Andrei Vagin <avagin@virtuozzo.com>

On Tue, Sep 04, 2018 at 05:28:13PM -0400, Daniel Jordan wrote:
> Pavel Tatashin, Ying Huang, and I are excited to be organizing a performance and scalability microconference this year at Plumbers[*], which is happening in Vancouver this year.  The microconference is scheduled for the morning of the second day (Wed, Nov 14).
> 
> We have a preliminary agenda and a list of confirmed and interested attendees (cc'ed), and are seeking more of both!
> 
> Some of the items on the agenda as it stands now are:
> 
>  - Promoting huge page usage:  With memory sizes becoming ever larger, huge pages are becoming more and more important to reduce TLB misses and the overhead of memory management itself--that is, to make the system scalable with the memory size.  But there are still some remaining gaps that prevent huge pages from being deployed in some situations, such as huge page allocation latency and memory fragmentation.
> 
>  - Reducing the number of users of mmap_sem:  This semaphore is frequently used throughout the kernel.  In order to facilitate scaling this longstanding bottleneck, these uses should be documented and unnecessary users should be fixed.
> 
>  - Parallelizing cpu-intensive kernel work:  Resolve problems of past approaches including extra threads interfering with other processes, playing well with power management, and proper cgroup accounting for the extra threads.  Bonus topic: proper accounting of workqueue threads running on behalf of cgroups.
> 
>  - Preserving userland during kexec with a hibernation-like mechanism.

Just some crazy idea: have you considered using checkpoint-restore as a
replacement or an addition to hibernation?
 
> These center around our interests, but having lots of topics to choose from ensures we cover what's most important to the community, so we would like to hear about additional topics and extensions to those listed here.  This includes, but is certainly not limited to, work in progress that would benefit from in-person discussion, real-world performance problems, and experimental and academic work.
> 
> If you haven't already done so, please let us know if you are interested in attending, or have suggestions for other attendees.
> 
> Thanks,
> Daniel
> 
> [*] https://blog.linuxplumbersconf.org/2018/performance-mc/
> 

-- 
Sincerely yours,
Mike.

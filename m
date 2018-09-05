Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A03656B73B9
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 11:10:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 123-v6so5381366qkl.3
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 08:10:40 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id f24-v6si509800qkm.396.2018.09.05.08.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 08:10:39 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:10:39 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
In-Reply-To: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
Message-ID: <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>brouer@redhat.com, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On Tue, 4 Sep 2018, Daniel Jordan wrote:

>  - Promoting huge page usage:  With memory sizes becoming ever larger, huge
> pages are becoming more and more important to reduce TLB misses and the
> overhead of memory management itself--that is, to make the system scalable
> with the memory size.  But there are still some remaining gaps that prevent
> huge pages from being deployed in some situations, such as huge page
> allocation latency and memory fragmentation.

You forgot the major issue that huge pages in the page cache are not
supported and thus we have performance issues with fast NVME drives that
are now able to do 3Gbytes per sec that are only possible to reach with
directio and huge pages.

IMHO the huge page issue is just the reflection of a certain hardware
manufacturer inflicting pain for over a decade on its poor users by not
supporting larger base page sizes than 4k. No such workarounds needed on
platforms that support large sizes. Things just zoom along without
contortions necessary to deal with huge pages etc.

Can we come up with a 2M base page VM or something? We have possible
memory sizes of a couple TB now. That should give us a million or so 2M
pages to work with.

>  - Reducing the number of users of mmap_sem:  This semaphore is frequently
> used throughout the kernel.  In order to facilitate scaling this longstanding
> bottleneck, these uses should be documented and unnecessary users should be
> fixed.


Large page sizes also reduce contention there.

> If you haven't already done so, please let us know if you are interested in
> attending, or have suggestions for other attendees.

Certainly interested in attending but this overlaps supercomputing 2018 in
Dallas Texas...

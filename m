Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80DD36B7635
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 21:58:27 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a10-v6so4672572pls.23
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 18:58:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e4-v6si3800224pgk.630.2018.09.05.18.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 18:58:26 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
	<01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
Date: Thu, 06 Sep 2018 09:58:17 +0800
In-Reply-To: <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
	(Christopher Lameter's message of "Wed, 5 Sep 2018 15:10:39 +0000")
Message-ID: <877ejzqtdy.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

Hi, Christopher,

Christopher Lameter <cl@linux.com> writes:

> On Tue, 4 Sep 2018, Daniel Jordan wrote:
>
>>  - Promoting huge page usage:  With memory sizes becoming ever larger, huge
>> pages are becoming more and more important to reduce TLB misses and the
>> overhead of memory management itself--that is, to make the system scalable
>> with the memory size.  But there are still some remaining gaps that prevent
>> huge pages from being deployed in some situations, such as huge page
>> allocation latency and memory fragmentation.
>
> You forgot the major issue that huge pages in the page cache are not
> supported and thus we have performance issues with fast NVME drives that
> are now able to do 3Gbytes per sec that are only possible to reach with
> directio and huge pages.

Yes.  That is an important gap for huge page.  Although we have huge
page cache support for tmpfs, we lacks that for normal file systems.

> IMHO the huge page issue is just the reflection of a certain hardware
> manufacturer inflicting pain for over a decade on its poor users by not
> supporting larger base page sizes than 4k. No such workarounds needed on
> platforms that support large sizes. Things just zoom along without
> contortions necessary to deal with huge pages etc.
>
> Can we come up with a 2M base page VM or something? We have possible
> memory sizes of a couple TB now. That should give us a million or so 2M
> pages to work with.

That sounds a good idea.  Don't know whether someone has tried this.

>>  - Reducing the number of users of mmap_sem:  This semaphore is frequently
>> used throughout the kernel.  In order to facilitate scaling this longstanding
>> bottleneck, these uses should be documented and unnecessary users should be
>> fixed.
>
>
> Large page sizes also reduce contention there.

Yes.

>> If you haven't already done so, please let us know if you are interested in
>> attending, or have suggestions for other attendees.
>
> Certainly interested in attending but this overlaps supercomputing 2018 in
> Dallas Texas...

Sorry to know this.  It appears that there are too many conferences in
November...

Best Regards,
Huang, Ying

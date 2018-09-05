Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 607BA6B7439
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:18:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so9228458oiw.13
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:18:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p72-v6si1632321oic.221.2018.09.05.09.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:18:14 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85GFO3g132091
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:18:13 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2maj5w1mbe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:18:13 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:18:10 +0100
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 5 Sep 2018 18:17:59 +0200
MIME-Version: 1.0
In-Reply-To: <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>



On 05/09/2018 17:10, Christopher Lameter wrote:
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
> 
> IMHO the huge page issue is just the reflection of a certain hardware
> manufacturer inflicting pain for over a decade on its poor users by not
> supporting larger base page sizes than 4k. No such workarounds needed on
> platforms that support large sizes. Things just zoom along without
> contortions necessary to deal with huge pages etc.
> 
> Can we come up with a 2M base page VM or something? We have possible
> memory sizes of a couple TB now. That should give us a million or so 2M
> pages to work with.
> 
>>  - Reducing the number of users of mmap_sem:  This semaphore is frequently
>> used throughout the kernel.  In order to facilitate scaling this longstanding
>> bottleneck, these uses should be documented and unnecessary users should be
>> fixed.
> 
> 
> Large page sizes also reduce contention there.

That's true for the page fault path, but for process's actions manipulating the
memory process's layout (mmap,munmap,madvise,mprotect) the impact is minimal
unless the code has to manipulate the page tables.

>> If you haven't already done so, please let us know if you are interested in
>> attending, or have suggestions for other attendees.
> 
> Certainly interested in attending but this overlaps supercomputing 2018 in
> Dallas Texas...
> 

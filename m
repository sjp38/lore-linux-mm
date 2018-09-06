Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B78CE6B7AD7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 17:36:54 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e15-v6so6426870pfi.5
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 14:36:54 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id u24-v6si6431386pgk.72.2018.09.06.14.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 14:36:53 -0700 (PDT)
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
 <877ejzqtdy.fsf@yhuang-dev.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bd6f6f8b-4880-6c20-62f5-bb6ca3b5e6f7@oracle.com>
Date: Thu, 6 Sep 2018 14:36:38 -0700
MIME-Version: 1.0
In-Reply-To: <877ejzqtdy.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Christopher Lameter <cl@linux.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, ldufour@linux.vnet.ibm.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tglx@linutronix.de, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>, Hugh Dickins <hughd@google.com>

On 09/05/2018 06:58 PM, Huang, Ying wrote:
> Hi, Christopher,
> 
> Christopher Lameter <cl@linux.com> writes:
> 
>> On Tue, 4 Sep 2018, Daniel Jordan wrote:
>>
>>>  - Promoting huge page usage:  With memory sizes becoming ever larger, huge
>>> pages are becoming more and more important to reduce TLB misses and the
>>> overhead of memory management itself--that is, to make the system scalable
>>> with the memory size.  But there are still some remaining gaps that prevent
>>> huge pages from being deployed in some situations, such as huge page
>>> allocation latency and memory fragmentation.
>>
>> You forgot the major issue that huge pages in the page cache are not
>> supported and thus we have performance issues with fast NVME drives that
>> are now able to do 3Gbytes per sec that are only possible to reach with
>> directio and huge pages.
> 
> Yes.  That is an important gap for huge page.  Although we have huge
> page cache support for tmpfs, we lacks that for normal file systems.
> 
>> IMHO the huge page issue is just the reflection of a certain hardware
>> manufacturer inflicting pain for over a decade on its poor users by not
>> supporting larger base page sizes than 4k. No such workarounds needed on
>> platforms that support large sizes. Things just zoom along without
>> contortions necessary to deal with huge pages etc.
>>
>> Can we come up with a 2M base page VM or something? We have possible
>> memory sizes of a couple TB now. That should give us a million or so 2M
>> pages to work with.
> 
> That sounds a good idea.  Don't know whether someone has tried this.

IIRC, Hugh Dickins and some others at Google tried going down this path.
There was a brief discussion at LSF/MM.  It is something I too would like
to explore in my spare time.

-- 
Mike Kravetz

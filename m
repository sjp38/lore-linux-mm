Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61F638E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 18:19:46 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p22-v6so1722516pfj.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 15:19:46 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 190-v6si2192170pfu.343.2018.09.12.15.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 15:19:44 -0700 (PDT)
Subject: Re: [Bug 201085] New: Kernel allows mlock() on pages in CMA without
 migrating pages out of CMA first
References: <bug-201085-27@https.bugzilla.kernel.org/>
 <20180912124727.fccccf432d2d8163ead79288@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6d38e089-6df4-ead7-4a9d-7277a2db5d7c@oracle.com>
Date: Wed, 12 Sep 2018 15:19:32 -0700
MIME-Version: 1.0
In-Reply-To: <20180912124727.fccccf432d2d8163ead79288@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, tpearson@raptorengineering.com, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>

On 09/12/2018 12:47 PM, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 11 Sep 2018 03:59:11 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=201085
>>
>>             Bug ID: 201085
>>            Summary: Kernel allows mlock() on pages in CMA without
>>                     migrating pages out of CMA first
>>            Product: Memory Management
>>            Version: 2.5
>>     Kernel Version: 4.18
>>           Hardware: All
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Page Allocator
>>           Assignee: akpm@linux-foundation.org
>>           Reporter: tpearson@raptorengineering.com
>>         Regression: No
>>
>> Pages allocated in CMA are not migrated out of CMA when non-CMA memory is
>> available and locking is attempted via mlock().  This can result in rapid
>> exhaustion of the CMA pool if memory locking is used by an application with
>> large memory requirements such as QEMU.
>>
>> To reproduce, on a dual-CPU (NUMA) POWER9 host try to launch a VM with mlock=on
>> and 1/2 or more of physical memory allocated to the guest.  Observe full CMA
>> pool depletion occurs despite plenty of normal free RAM available.
>>
>> -- 
>> You are receiving this mail because:
>> You are the assignee for the bug.

IIRC, Aneesh is working on some powerpc IOMMU patches for a similar issue
(long term pinning of cma pages).  Added him on Cc:
https://lkml.kernel.org/r/20180906054342.25094-2-aneesh.kumar@linux.ibm.com

This report seems to be suggesting a more general solution/change.  Wondering
if there is any overlap with this and Aneesh's work.
-- 
Mike Kravetz

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7A96B779E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:45:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r131-v6so11965414oie.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:45:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v3-v6si2856562oiv.323.2018.09.06.00.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:45:22 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w867j9qX126379
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 03:45:22 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mayddj0nk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 03:45:21 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 6 Sep 2018 08:45:17 +0100
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <01000165aa490dc9-64abf872-afd1-4a81-a46d-a50d0131de93-000000@email.amazonses.com>
 <839e2703-1588-0873-00a7-d04810f403cf@linux.vnet.ibm.com>
 <alpine.DEB.2.21.1809060059390.1416@nanos.tec.linutronix.de>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 6 Sep 2018 09:45:05 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809060059390.1416@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <4d6a466c-6f77-b54e-fb30-9ad8e5bb4023@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christopher Lameter <cl@linux.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, alex.kogan@oracle.com, akpm@linux-foundation.org, boqun.feng@gmail.com, brouer@redhat.com, dave@stgolabs.net, dave.dice@oracle.com, Dhaval Giani <dhaval.giani@oracle.com>, ktkhai@virtuozzo.com, Pavel.Tatashin@microsoft.com, paulmck@linux.vnet.ibm.com, shady.issa@oracle.com, tariqt@mellanox.com, tim.c.chen@intel.com, vbabka@suse.cz, longman@redhat.com, yang.shi@linux.alibaba.com, shy828301@gmail.com, Huang Ying <ying.huang@intel.com>, subhra.mazumdar@oracle.com, Steven Sistare <steven.sistare@oracle.com>, jwadams@google.com, ashwinch@google.com, sqazi@google.com, Shakeel Butt <shakeelb@google.com>, walken@google.com, rientjes@google.com, junaids@google.com, Neha Agarwal <nehaagarwal@google.com>

On 06/09/2018 01:01, Thomas Gleixner wrote:
> On Wed, 5 Sep 2018, Laurent Dufour wrote:
>> On 05/09/2018 17:10, Christopher Lameter wrote:
>>> Large page sizes also reduce contention there.
>>
>> That's true for the page fault path, but for process's actions manipulating the
>> memory process's layout (mmap,munmap,madvise,mprotect) the impact is minimal
>> unless the code has to manipulate the page tables.
> 
> And how exactly are you going to do any of those operations _without_
> manipulating the page tables?

I agree, at one time the page tables would have to be manipulated, and this is
mostly done under the protection of the page table locks - should the mmap_sem
still being held then ?

I was thinking about all the processing done on the VMAs, accounting, etc.
That part, usually not manipulating the page tables, is less dependent of the
underlying page size.

But I agree at one time of the processing, the page table are manipulated and
dealing with larger pages is better then.

Thanks,
Laurent.

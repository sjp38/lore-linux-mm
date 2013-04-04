Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 3B5016B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 04:38:25 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 14:03:50 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 20E8E394002D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 14:08:18 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r348cEk63801410
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 14:08:14 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r348cGL3021084
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 19:38:17 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 00/25] THP support for PPC64
In-Reply-To: <515D1A2C.1000606@gmail.com>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <515D1A2C.1000606@gmail.com>
Date: Thu, 04 Apr 2013 14:08:15 +0530
Message-ID: <878v4y4rns.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Simon Jeons <simon.jeons@gmail.com> writes:

> Hi Aneesh,
> On 04/04/2013 01:57 PM, Aneesh Kumar K.V wrote:
>> Hi,
>>
>> This patchset adds transparent hugepage support for PPC64.
>>
>> TODO:
>> * hash preload support in update_mmu_cache_pmd (we don't do that for hugetlb)
>>
>> Some numbers:
>>
>> The latency measurements code from Anton  found at
>> http://ozlabs.org/~anton/junkcode/latency2001.c
>>
>> THP disabled 64K page size
>> ------------------------
>> [root@llmp24l02 ~]# ./latency2001 8G
>>   8589934592    731.73 cycles    205.77 ns
>> [root@llmp24l02 ~]# ./latency2001 8G
>>   8589934592    743.39 cycles    209.05 ns
>
> Could you explain what's the meaning of result?
>

That is the total memory range, cycles taken to access an address and
time taken to access. That numbers shows the overhead of tlb miss.

you can find the source at http://ozlabs.org/~anton/junkcode/latency2001.c


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 706D76B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:49:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w10so736175wrg.15
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 00:49:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 7si81733edk.519.2018.03.28.00.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 00:49:43 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2S7YS9C043641
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:49:42 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h03xqy14c-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:49:42 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 08:49:40 +0100
Subject: Re: [PATCH v9 01/24] mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803251442090.80485@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 09:49:29 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803251442090.80485@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <32c80b6a-28c6-bf63-ed7b-6a042ae18e8f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi David,

Thanks a lot for your deep review on this series.

On 25/03/2018 23:50, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
>> This configuration variable will be used to build the code needed to
>> handle speculative page fault.
>>
>> By default it is turned off, and activated depending on architecture
>> support.
>>
>> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/Kconfig | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index abefa573bcd8..07c566c88faf 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -759,3 +759,6 @@ config GUP_BENCHMARK
>>  	  performance of get_user_pages_fast().
>>  
>>  	  See tools/testing/selftests/vm/gup_benchmark.c
>> +
>> +config SPECULATIVE_PAGE_FAULT
>> +       bool
> 
> Should this be configurable even if the arch supports it?

Actually, this is not configurable unless by manually editing the .config file.

I made it this way on the Thomas's request :
https://lkml.org/lkml/2018/1/15/969

That sounds to be the smarter way to achieve that, isn't it ?

Laurent.

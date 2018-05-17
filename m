Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 295F46B051E
	for <linux-mm@kvack.org>; Thu, 17 May 2018 13:35:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so1826474pld.23
        for <linux-mm@kvack.org>; Thu, 17 May 2018 10:35:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q17-v6si5500643pff.301.2018.05.17.10.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 10:35:08 -0700 (PDT)
Subject: Re: [PATCH v11 01/26] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1526555193-7242-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <2cb8256d-5822-d94d-b0e6-c46f21d84852@infradead.org>
 <20180517171951.GB26718@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <b5df0b34-5c7b-6d8c-d29d-bc6fb4e51023@infradead.org>
Date: Thu, 17 May 2018 10:34:53 -0700
MIME-Version: 1.0
In-Reply-To: <20180517171951.GB26718@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 05/17/2018 10:19 AM, Matthew Wilcox wrote:
> On Thu, May 17, 2018 at 09:36:00AM -0700, Randy Dunlap wrote:
>>> +	 If the speculative page fault fails because of a concurrency is
>>
>> 	                                     because a concurrency is
> 
> While one can use concurrency as a noun, it sounds archaic to me.  I'd
> rather:
> 
> 	If the speculative page fault fails because a concurrent modification
> 	is detected or because underlying PMD or PTE tables are not yet

Yeah, OK.

>>> +	 detected or because underlying PMD or PTE tables are not yet
>>> +	 allocating, it is failing its processing and a classic page fault
>>
>> 	 allocated, the speculative page fault fails and a classic page fault
>>
>>> +	 is then tried.


-- 
~Randy

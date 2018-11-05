Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1C96B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:09:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t21-v6so2145727edq.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:09:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c58-v6si13230713ede.329.2018.11.05.08.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:09:04 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA5G6CVs064205
	for <linux-mm@kvack.org>; Mon, 5 Nov 2018 11:09:02 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2njrqh1760-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Nov 2018 11:09:01 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@liunx.vnet.ibm.com>;
	Mon, 5 Nov 2018 16:08:58 -0000
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20181105104204.GB9042@350D>
From: Laurent Dufour <ldufour@liunx.vnet.ibm.com>
Date: Mon, 5 Nov 2018 17:08:45 +0100
MIME-Version: 1.0
In-Reply-To: <20181105104204.GB9042@350D>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <8dce53f8-b085-c4a7-3d87-de66bbcdc18c@liunx.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Le 05/11/2018 A  11:42, Balbir Singh a A(C)critA :
> On Thu, May 17, 2018 at 01:06:07PM +0200, Laurent Dufour wrote:
>> This is a port on kernel 4.17 of the work done by Peter Zijlstra to handle
>> page fault without holding the mm semaphore [1].
>>
>> The idea is to try to handle user space page faults without holding the
>> mmap_sem. This should allow better concurrency for massively threaded
> 
> Question -- I presume mmap_sem (rw_semaphore implementation tested against)
> was qrwlock?

I don't think so, this series doesn't change the mmap_sem definition so 
it still belongs to the 'struct rw_semaphore'.

Laurent.

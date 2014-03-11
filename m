Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 61E0E6B0035
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 17:02:55 -0400 (EDT)
Received: by mail-yh0-f46.google.com with SMTP id b6so6261072yha.5
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 14:02:55 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v46si38327526yhh.87.2014.03.11.14.02.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 14:02:54 -0700 (PDT)
Message-ID: <531F79F7.5090201@oracle.com>
Date: Tue, 11 Mar 2014 17:02:47 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: mmap_sem lock assertion failure in __mlock_vma_pages_range
References: <531F6689.60307@oracle.com>		<1394568453.2786.28.camel@buesod1.americas.hpqcorp.net>	 <20140311133051.bf5ca716ef189746ebcff431@linux-foundation.org>	 <531F75D1.3060909@oracle.com> <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1394570844.2786.42.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On 03/11/2014 04:47 PM, Davidlohr Bueso wrote:
>> Bingo! With the above patch:
>> >
>> >[  243.565794] kernel BUG at mm/vmacache.c:76!
>> >[  243.566720] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>> >[  243.568048] Dumping ftrace buffer:
>> >[  243.568740]    (ftrace buffer empty)
>> >[  243.569481] Modules linked in:
>> >[  243.570203] CPU: 10 PID: 10073 Comm: trinity-c332 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00010-g1f812cb-dirty #143
> and this is also part of the DEBUG_PAGEALLOC + trinity combo! I suspect
> the root cause it the same as Fengguang's report.

The BUG still happens without DEBUG_PAGEALLOC.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9S1ReBN014698
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 21:27:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9S1RdOO056630
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 21:27:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9S1RdIY022295
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 21:27:39 -0400
Message-ID: <43617E87.4040605@us.ibm.com>
Date: Thu, 27 Oct 2005 18:27:35 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <1130366995.23729.38.camel@localhost.localdomain>	<200510271038.52277.ak@suse.de>	<20051027131725.GI5091@opteron.random>	<1130425212.23729.55.camel@localhost.localdomain>	<20051027151123.GO5091@opteron.random>	<20051027112054.10e945ae.akpm@osdl.org>	<20051027200434.GT5091@opteron.random>	<20051027135058.2f72e706.akpm@osdl.org>	<20051027213721.GX5091@opteron.random>	<20051027152340.5e3ae2c6.akpm@osdl.org>	<20051028002231.GC5091@opteron.random> <20051027173243.41ecd335.akpm@osdl.org>
In-Reply-To: <20051027173243.41ecd335.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> 
>>>- View it as a filesystem operation which has MM side-effects.
>>
>> I suggested the fs operation too but then it's more efficient to have it
>> as a mm operation with fs side effects, because they don't immediatly
>> know fd and physical offset of the range. It's possible to fixup in
>> userland and to use the fs operation but it's more expensive, the vmas
>> are already in the kernel and we can use them.
> 
> 
> hm, so we have a somewhat awkward interface to a very specific thing to
> benefit a closed-source app.  That'll go down well ;)
> 

I am not sure how apps can work out (fd, phys off, len) for a given
shared memory segment range easily.

> ho-hum.  Can we think of a better name than MADV_TRUNCATE please?  Dunno
> what - MADV_REMOVE?

how about - MADV_DISCARD :) Just kidding - MADV_REMOVE is a good
name.

I am still not clear on the consensus here - the plan is go forward
with the patch (ofcourse, naming changes) and may be later add
(fd, offset, len) version of it through sys_holepunch ?

If so, I can quickly redo my patch + I need to work out bugs in
shm_truncate_range().

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

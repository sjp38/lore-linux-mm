Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RNLMBw019090
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 19:21:22 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RNLLl1110102
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 19:21:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9RNLLt0000876
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 19:21:21 -0400
Message-ID: <436160F0.8050609@us.ibm.com>
Date: Thu, 27 Oct 2005 16:21:20 -0700
From: Darren Hart <dvhltc@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <E1EVDbZ-0004fp-00@w-gerrit.beaverton.ibm.com> <200510272156.03276.ak@suse.de>
In-Reply-To: <200510272156.03276.ak@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Gerrit Huizenga <gh@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, hugh@veritas.com, jdike@addtoit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Thursday 27 October 2005 21:40, Gerrit Huizenga wrote:
> 
> 
>> I believe Java uses mmap() today for this; DB2 probably uses both mmap()
>> and shm*().
> 
> 
> In the java case the memory should be anonymous, no? This means just plain
> munmap would work. Or do I miss something?

I believe it was mentioned earlier (Andrea in reply to Ted) that 
madvise(MADV_DONTNEED) would work in the anonymous case.

> 
> -Andi
> 
>  
> 


-- 
Darren Hart
IBM Linux Technology Center
Linux Kernel Team
Phone: 503 578 3185
   T/L: 775 3185

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAC4fAfM009379
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 23:41:10 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jAC4fAZl112272
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 23:41:10 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAC4fAGR003488
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 23:41:10 -0500
Message-ID: <43757263.2030401@us.ibm.com>
Date: Fri, 11 Nov 2005 20:41:07 -0800
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE)
References: <1130366995.23729.38.camel@localhost.localdomain>	<20051028034616.GA14511@ccure.user-mode-linux.org>	<43624F82.6080003@us.ibm.com>	<20051028184235.GC8514@ccure.user-mode-linux.org>	<1130544201.23729.167.camel@localhost.localdomain>	<20051029025119.GA14998@ccure.user-mode-linux.org>	<1130788176.24503.19.camel@localhost.localdomain>	<20051101000509.GA11847@ccure.user-mode-linux.org>	<1130894101.24503.64.camel@localhost.localdomain>	<20051102014321.GG24051@opteron.random>	<1130947957.24503.70.camel@localhost.localdomain>	<20051111162511.57ee1af3.akpm@osdl.org>	<1131755660.25354.81.camel@localhost.localdomain> <20051111174309.5d544de4.akpm@osdl.org>
In-Reply-To: <20051111174309.5d544de4.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: andrea@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
>>>Why does madvise_remove() have an explicit check for swapper_space?
>>
>>I really don't remember (I yanked code from some other kernel routine
>>vmtruncate()).
> 
> 
> I don't see such a thing anywhere.  vmtruncate() has the IS_SWAPFILE()
> test, which I guess vmtruncate_range() ought to have too, for
> future-safety.

Yep. That was the check. Since I don't have inode and have mapping
handy anyway, check was made using that. I could change it, if you wish.

> 
> Logically, vmtruncate() should just be a special case of vmtruncate_range().
> But it's not - ugly, but hard to do anything about (need to implement
> ->truncate_range in all filesystems, but "know" which ones only support
> ->truncate_range() at eof).
> 
> 
>>>In your testing, how are you determining that the code is successfully
>>>removing the correct number of pages, from the correct file offset?
>>
>>I verified with test programs, added debug printk + looked through live
>>"crash" session + verified with UML testcases.
> 
> 
> OK, well please be sure to test it on 32-bit and 64-bit, operating in three
> ranges of the file: <2G, 2G-4G amd >4G.
> 
Will do.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0SGrvhU008696
	for <linux-mm@kvack.org>; Sat, 28 Jan 2006 11:53:58 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0SGrvrY150718
	for <linux-mm@kvack.org>; Sat, 28 Jan 2006 11:53:57 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0SGrvbv022834
	for <linux-mm@kvack.org>; Sat, 28 Jan 2006 11:53:57 -0500
Message-ID: <43DBA1A0.6010708@us.ibm.com>
Date: Sat, 28 Jan 2006 08:53:52 -0800
From: Sridhar Samudrala <sri@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com> <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com> <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com> <43D96A93.9000600@us.ibm.com> <20060127025126.c95f8002.pj@sgi.com> <43DAC222.4060805@us.ibm.com> <20060128081641.GB1605@elf.ucw.cz> <43DB9877.7020206@us.ibm.com> <20060128164158.GD1858@elf.ucw.cz>
In-Reply-To: <20060128164158.GD1858@elf.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Matthew Dobson <colpatch@us.ibm.com>, Paul Jackson <pj@sgi.com>, clameter@engr.sgi.com, linux-kernel@vger.kernel.org, andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Pavel Machek wrote:
>>>> I still think some sort of reserve pool
>>>> is necessary to give the networking stack a little breathing room when
>>>> under both memory pressure and network load.
>>>>    
>>>>         
>>> "Lets throw some memory there and hope it does some good?" Eek? What
>>> about auditing/fixing the networking stack, instead?
>>>  
>>>       
>> The other reason we need a separate critical pool is to satifsy critical 
>> GFP_KERNEL allocations
>> when we are in emergency. These are made in the send side and we cannot 
>> block/sleep.
>>     
>
> If sending routines can work with constant ammount of memory, why use
> kmalloc at all? Anyway I thought we were talking receiving side
> earlier in the thread.
>
> Ouch and wait a moment. You claim that GFP_KERNEL allocations can't
> block/sleep? Of course they can, that's why they are GFP_KERNEL and
> not GFP_ATOMIC.
>   
I didn't meant GFP_KERNEL allocations cannot block/sleep? When in 
emergency, we
want even the GFP_KERNEL allocations that are made by critical sockets 
not to block/sleep.
So my original critical sockets patches changes the gfp flag passed to 
these allocation requests
to GFP_KERNEL|GFP_CRITICAL.

Thanks
Sridhar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

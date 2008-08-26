Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7QDFc5e014517
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 18:45:38 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7QDFb5T1761512
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 18:45:38 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7QDFbYX029212
	for <linux-mm@kvack.org>; Tue, 26 Aug 2008 18:45:37 +0530
Message-ID: <48B401F8.9010703@linux.vnet.ibm.com>
Date: Tue, 26 Aug 2008 18:45:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B3E4CC.9060309@linux.vnet.ibm.com> <48B3F04B.9030308@iplabs.de>
In-Reply-To: <48B3F04B.9030308@iplabs.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Nietz <m.nietz-mm@iplabs.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marco Nietz wrote:
> Balbir Singh schrieb:
> 
>>> DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
>>> present:0kB pages_scanned:0 all_unreclaimable? no
>>> lowmem_reserve[]: 0 0 880 17392
>> pages_scanned is 0
> 
> Is'nt this zone irrelevant for a 32bit Kernel ?
> 

Doesn't matter, since you have 0 present pages.

>>> Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB
>>> inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
>>> lowmem_reserve[]: 0 0 0 132096
>> pages_scanned is 593 and all_unreclaimable is yes
> 
> Reclaimable means, that the Pages are reusable for other Purposes, or not ?
>

It is set by a background routine that tries to reclaim pages (balance_pgdat()),
to indicate that it was unable to reclaim any pages from the zone, even though
it did a certain amount of work to do so.

>>> HighMem free:5941820kB min:512kB low:18148kB high:35784kB
>>> active:4408096kB inactive:5494404kB present:16908288kB pages_scanned:0
>>> all_unreclaimable? no
>> pages_scanned is 0
> 
>> Do you have CONFIG_HIGHPTE set? I suspect you don't (I don't really know the
>> debian etch configuration)
> 
> No, it's not set in the running Debian Kernel.

Looks like CONFIG_HIGHPTE=y would have helped allocate pages since you do have
pages in HighMem available.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

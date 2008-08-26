Message-ID: <48B3F04B.9030308@iplabs.de>
Date: Tue, 26 Aug 2008 14:00:11 +0200
From: Marco Nietz <m.nietz-mm@iplabs.de>
MIME-Version: 1.0
Subject: Re: oom-killer why ?
References: <48B296C3.6030706@iplabs.de> <48B3E4CC.9060309@linux.vnet.ibm.com>
In-Reply-To: <48B3E4CC.9060309@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh schrieb:

>> DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB
>> present:0kB pages_scanned:0 all_unreclaimable? no
>> lowmem_reserve[]: 0 0 880 17392
> 
> pages_scanned is 0

Is'nt this zone irrelevant for a 32bit Kernel ?

>> Normal free:3664kB min:3756kB low:4692kB high:5632kB active:280kB
>> inactive:244kB present:901120kB pages_scanned:593 all_unreclaimable? yes
>> lowmem_reserve[]: 0 0 0 132096
> 
> pages_scanned is 593 and all_unreclaimable is yes

Reclaimable means, that the Pages are reusable for other Purposes, or not ?

>> HighMem free:5941820kB min:512kB low:18148kB high:35784kB
>> active:4408096kB inactive:5494404kB present:16908288kB pages_scanned:0
>> all_unreclaimable? no
> 
> pages_scanned is 0

> Do you have CONFIG_HIGHPTE set? I suspect you don't (I don't really know the
> debian etch configuration)

No, it's not set in the running Debian Kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

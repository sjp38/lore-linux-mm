Date: Thu, 13 Jan 2000 18:06:07 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001131430520.13454-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001131803330.1648-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Rik van Riel wrote:

>On Wed, 12 Jan 2000, Kanoj Sarcar wrote:
>
>> --- mm/page_alloc.c	Tue Jan 11 11:00:31 2000
>> +++ mm/page_alloc.c	Tue Jan 11 23:59:35 2000
>> +		cumulative += size;
>> +		mask = (cumulative >> 7);
>> +		if (mask < 1) mask = 1;
>> +		zone->pages_low = mask*2;
>> +		zone->pages_high = mask*3;
>>  		zone->low_on_memory = 0;
>
>I think that busier machines probably have a larger need
>for DMA memory than this code fragment will give us. I
>have the gut feeling that we'll want to keep about 512kB
>or more free in the lower 16MB of busy machines...
>
>(if only because such a large amount of free pages in
>such a small part of the address space will give us
>higher-order free pages)

That's only a workaround because the page-freeing mechanism is currently
not aware about fragmentation and about the order of the request we asked
for.

So such code shouldn't be wrote assuming the page-freeing is weak as now.

Supposing it's smart we don't need to take lots of memory free in the dma
zone to allow high order allocations to succeed.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

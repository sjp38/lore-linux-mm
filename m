Message-ID: <45347288.6040808@yahoo.com.au>
Date: Tue, 17 Oct 2006 16:04:56 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Page allocator: Single Zone optimizations
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com> <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>On Tue, 17 Oct 2006, KAMEZAWA Hiroyuki wrote:
>
>
>>How about defining following instead of inserting #ifdefs ?
>>
>>#ifdef ZONES_SHIFT > 0
>>#define zone_lowmem_reserve(z, i)	((z)->lowmem_reserve[(i)])
>>#else
>>#define zone_lowmem_reserve(z, i)	(0)
>>#endif
>>
>>and removing #if's from *.c files ? Can't this be help ?
>>
>
>Well it only shifts the #ifdef elsewhere.... 
>

Shifting this out of the caller like this tends to be the accepted
way of doing it. It does tend to be more readable.

I would give an ack to Kame's approach for lowmem_reserve ;)

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <448E3EA8.3020807@yahoo.com.au>
Date: Tue, 13 Jun 2006 14:27:20 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of physical
 pages backing it
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <200606121958.41127.ak@suse.de> <1150141369.9576.43.camel@galaxy.corp.google.com> <200606130551.23825.ak@suse.de>
In-Reply-To: <200606130551.23825.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: rohitseth@google.com, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>On Monday 12 June 2006 21:42, Rohit Seth wrote:
>
>>I think having this 
>>information in each vma keeps the impact (of adding new counter) to very
>>low.
>>
>>Second question is to advertize this value to user space.  Please let me
>>know what suites the most among /proc, /sys or system call (or if there
>>is any other mechanism then let me know) for a per process per segment
>>related information.
>>
>
>I think we first need to identify the basic need.
>Don't see why we even need per VMA information so far.
>

Exactly. There is no question that walking page tables will be slower
than having a counter like your patch does; the question is why we
need it.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

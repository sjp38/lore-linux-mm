Message-ID: <41E8F313.4030102@yahoo.com.au>
Date: Sat, 15 Jan 2005 21:40:19 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
References: <20050113061401.GA7404@blackham.com.au>	 <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au>	 <20050113101426.GA4883@blackham.com.au>  <41E8ED89.8090306@yahoo.com.au> <1105785254.13918.4.camel@desktop.cunninghams>
In-Reply-To: <1105785254.13918.4.camel@desktop.cunninghams>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@linuxmail.org
Cc: Bernard Blackham <bernard@blackham.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nigel Cunningham wrote:
> Hi Nick and Bernard.
> 
> On Sat, 2005-01-15 at 21:16, Nick Piggin wrote:
> 
>>OK I think the problem is due to swsusp allocating a very large
>>chunk of memory before suspending. After resuming, kswapd is more
>>or less in the same state and tries a bit too hard to free things.
> 
> 
> I'm not sure about this theory. The normal case will be that all
> allocations (maybe one or two order 1 or order 2 allocations if I've
> forgotten something) are order 0 and processes are thawed after we've
> freed all the memory we were using. Could that still trigger kswapd?
> 

I've seen try to do order 8 allocations or something almost as
ridiculous. Atomic too.

Well, correction, I've seen _reports_. Never tried swsusp myself.

I don't think a few order 0 and 1 allocations would do any harm
because otherwise every man and his dog would be having problems.

> 
>>Thanks for the report... I'll come up with something for you to try
>>in the next day or so.
> 
> 
> I'm flying to America on Monday, but I'll try to keep up with the
> progress in this and do anything I can to help.
> 

It is basically a problem with one of my patches. I should be able
to fix it (although fixing swsusp would be nice too :) ).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 05D6D6B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 03:18:55 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so2876264pde.13
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 00:18:55 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id pi8si3170652pac.117.2014.01.09.00.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 00:18:54 -0800 (PST)
Message-ID: <52CE5B58.8080203@oracle.com>
Date: Thu, 09 Jan 2014 16:18:32 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: swap, compress, discard: what's in the future?
References: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>	<20140107030148.GA24188@bbox> <CAA_GA1d==iPO_Ne4c5xFBdgUnhsehcod+5ZnZNajWvk8-ak1bg@mail.gmail.com> <52CC04DD.3020603@redhat.com>
In-Reply-To: <52CC04DD.3020603@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, Linux-MM <linux-mm@kvack.org>, hnaz@cmpxchg.org


On 01/07/2014 09:45 PM, Rik van Riel wrote:
> On 01/07/2014 01:33 AM, Bob Liu wrote:
>> On Tue, Jan 7, 2014 at 11:01 AM, Minchan Kim <minchan@kernel.org> wrote:
> 
>>> Your statement makes sense to me but unfortunately, current VM doesn't
>>> consider everything you mentioned.
>>> It is just based on page access recency by approximate LRU logic +
>>> some heuristic(ex, mapped page and VM_EXEC pages are more precious).
>>
>> It seems that the ARC page replacement algorithm in zfs have good
>> performance and more intelligent.
>> http://en.wikipedia.org/wiki/Adaptive_replacement_cache
>> Is there any history reason of linux didn't implement something like
>> ARC as the page cache replacement algorithm?
> 
> ARC by itself was quickly superceded by CLOCK-Pro, which
> looks like it would be even better.
> 
> Johannes introduces an algorithm with similar properties
> in his "thrash based page cache replacement" patch series.
> 

But it seems you and Peter have already implemented CLOCK-Pro and CART
page cache replacement many years ago. Why they were not get merged at
that time?

I found some information from
http://linux-mm.org/AdvancedPageReplacement

Linux implementations:
Rahul Iyer's implementation of CART, RahulIyerCART

Rik van Riel's ClockProApproximation.

Rik van Riel's proposal for the tracking of NonResidentPages, which is
used by both his ClockProApproximation and by Peter Zijlstra's CART and
Clock-pro implementations.

Peter Zijlstra's CART PeterZCart

Peter Zijlstra's Clock-Pro PeterZClockPro2

Thanks,
-Bob

> However, algorithms like ARC and clockpro are best for
> a cache that caches a large data set (much larger than
> the cache size), and has to deal with large inter-reference
> distances.
> 
> For anonymous memory, we are dealing with the opposite:
> the total amount of anonymous memory is on the same
> order of magnitude as the amount of RAM, and the
> inter-reference distance will be smaller as a result.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

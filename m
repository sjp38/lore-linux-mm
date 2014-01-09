Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE1E6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 11:42:11 -0500 (EST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so2532453veb.5
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 08:42:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f9si5984099qar.190.2014.01.09.08.42.09
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 08:42:10 -0800 (PST)
Message-ID: <52CED13E.50700@redhat.com>
Date: Thu, 09 Jan 2014 11:41:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: swap, compress, discard: what's in the future?
References: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>	<20140107030148.GA24188@bbox> <CAA_GA1d==iPO_Ne4c5xFBdgUnhsehcod+5ZnZNajWvk8-ak1bg@mail.gmail.com> <52CC04DD.3020603@redhat.com> <52CE5B58.8080203@oracle.com>
In-Reply-To: <52CE5B58.8080203@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, Linux-MM <linux-mm@kvack.org>, hnaz@cmpxchg.org

On 01/09/2014 03:18 AM, Bob Liu wrote:
>
> On 01/07/2014 09:45 PM, Rik van Riel wrote:
>> On 01/07/2014 01:33 AM, Bob Liu wrote:
>>> On Tue, Jan 7, 2014 at 11:01 AM, Minchan Kim <minchan@kernel.org> wrote:
>>
>>>> Your statement makes sense to me but unfortunately, current VM doesn't
>>>> consider everything you mentioned.
>>>> It is just based on page access recency by approximate LRU logic +
>>>> some heuristic(ex, mapped page and VM_EXEC pages are more precious).
>>>
>>> It seems that the ARC page replacement algorithm in zfs have good
>>> performance and more intelligent.
>>> http://en.wikipedia.org/wiki/Adaptive_replacement_cache
>>> Is there any history reason of linux didn't implement something like
>>> ARC as the page cache replacement algorithm?
>>
>> ARC by itself was quickly superceded by CLOCK-Pro, which
>> looks like it would be even better.
>>
>> Johannes introduces an algorithm with similar properties
>> in his "thrash based page cache replacement" patch series.
>>
>
> But it seems you and Peter have already implemented CLOCK-Pro and CART
> page cache replacement many years ago. Why they were not get merged at
> that time?

Scalability concerns, lack of time, and the VM not being
ready to take the code.

The split LRU code makes it much more logical to merge a
replacement scheme that is suitable for second level
caches, because the anonymous memory is in an LRU scheme
that is more suitable to its kind of usage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

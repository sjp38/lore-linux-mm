Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id 261CB6B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 08:45:18 -0500 (EST)
Received: by mail-ve0-f172.google.com with SMTP id jw12so110913veb.31
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 05:45:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id sr1si1911665vdc.78.2014.01.07.05.45.16
        for <linux-mm@kvack.org>;
        Tue, 07 Jan 2014 05:45:16 -0800 (PST)
Message-ID: <52CC04DD.3020603@redhat.com>
Date: Tue, 07 Jan 2014 08:45:01 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: swap, compress, discard: what's in the future?
References: <CAA25o9Q921VnXvTo2OhXK5taif6MSF6LBtgPKve=kpgeW5XQ9Q@mail.gmail.com>	<20140107030148.GA24188@bbox> <CAA_GA1d==iPO_Ne4c5xFBdgUnhsehcod+5ZnZNajWvk8-ak1bg@mail.gmail.com>
In-Reply-To: <CAA_GA1d==iPO_Ne4c5xFBdgUnhsehcod+5ZnZNajWvk8-ak1bg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, Linux-MM <linux-mm@kvack.org>, hnaz@cmpxchg.org

On 01/07/2014 01:33 AM, Bob Liu wrote:
> On Tue, Jan 7, 2014 at 11:01 AM, Minchan Kim <minchan@kernel.org> wrote:

>> Your statement makes sense to me but unfortunately, current VM doesn't
>> consider everything you mentioned.
>> It is just based on page access recency by approximate LRU logic +
>> some heuristic(ex, mapped page and VM_EXEC pages are more precious).
> 
> It seems that the ARC page replacement algorithm in zfs have good
> performance and more intelligent.
> http://en.wikipedia.org/wiki/Adaptive_replacement_cache
> Is there any history reason of linux didn't implement something like
> ARC as the page cache replacement algorithm?

ARC by itself was quickly superceded by CLOCK-Pro, which
looks like it would be even better.

Johannes introduces an algorithm with similar properties
in his "thrash based page cache replacement" patch series.

However, algorithms like ARC and clockpro are best for
a cache that caches a large data set (much larger than
the cache size), and has to deal with large inter-reference
distances.

For anonymous memory, we are dealing with the opposite:
the total amount of anonymous memory is on the same
order of magnitude as the amount of RAM, and the
inter-reference distance will be smaller as a result.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <45E8CFD8.7050808@redhat.com>
Date: Fri, 02 Mar 2007 20:31:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] free swap space of (re)activated pages
References: <45E88997.4050308@redhat.com> <20070302171818.d271348e.akpm@linux-foundation.org>
In-Reply-To: <20070302171818.d271348e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 02 Mar 2007 15:31:19 -0500
> Rik van Riel <riel@redhat.com> wrote:
> 
>> the attached patch frees the swap space of already resident pages
>> when swap space starts getting tight, instead of only freeing up
>> the swap space taken up by newly swapped in pages.
>>
>> This should result in the swap space of pages that remain resident
>> in memory being freed, allowing kswapd more chances to actually swap
>> a page out (instead of rotating it back onto the active list).
> 
> Fair enough.   How do we work out if this helps things?

I suspect it should mostly help on desktop systems that slowly
fill up (and run out of) swap.  I'm not sure how to create that
synthetically.

I have seen that swap is kept free much easier in a qsbench
test, but that's probably not a very good test since it swaps
things in and out all the time...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

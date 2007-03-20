Message-ID: <45FFD34F.10809@redhat.com>
Date: Tue, 20 Mar 2007 08:27:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #2
References: <45FF3052.0@redhat.com> <45FF7B3A.70709@yahoo.com.au>
In-Reply-To: <45FF7B3A.70709@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Rik van Riel wrote:

>> We apply pressure to each of sets of the pageout queues based on:
>> - the size of each queue
>> - the fraction of recently referenced pages in each queue,
>>    not counting used-once file pages
>> - swappiness (file IO is more efficient than swap IO)

> This ignores whether a file page is mapped, doesn't it?

> Even so, it could be a good approach anyway.

It does, but once it gets the file list down to the size
where it finds that a fair number of the pages were
referenced, it will back off the pressure automatically.

Also, we do not apply the used-once algorithm to mapped
pages, meaning that mapped pages with the accessed bit
set always get rotated back onto the active list, while
unmapped pages do not.

> There are a couple of little nice improvements you have there, such as
> treating shmem pages in the same class as anon pages. We found that we
> needed something similar, so some of those things should go upstream
> on their own.

It will be hard to merge that "on its own" without the
split queues.  I can't really think of a good way to
split this patch up into multiple functional bits...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

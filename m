Message-ID: <452F323D.2040600@yahoo.com.au>
Date: Fri, 13 Oct 2006 16:29:17 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Driver-driven paging?
References: <452A68E9.3000707@tungstengraphics.com> <452A7AD3.5050006@yahoo.com.au> <452E8849.8050201@surriel.com>
In-Reply-To: <452E8849.8050201@surriel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Thomas Hellstrom <thomas@tungstengraphics.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> Nick Piggin wrote:
>
>> Your best bet might be to have a userspace "memory manager" process, 
>> which
>> allocates pages (anonymous or file backed), and has your device driver
>> access them with get_user_pages. The get_user_pages takes care of 
>> faulting
>> the pages back in, and when they are released, the memory manager will
>> swap them out on demand.
>
>
> Wouldn't tmpfs be simpler ?


It could be... actually having the pages inserted into a tmpfs filesystem
by the kernel does sound better than having it try to use the swap code
directly. I still don't know that tmpfs could quite handle that yet, but it
does sound like an interesting avenue (or maybe making your own filesystem
using some tmpfs interfaces). Good idea.

For an initial cut, I think having a memory manager process will work today,
and should do everything needed. So it might be a good way to quickly
evaluate the functionality.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

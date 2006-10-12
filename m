Message-ID: <452E8849.8050201@surriel.com>
Date: Thu, 12 Oct 2006 14:24:09 -0400
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: Driver-driven paging?
References: <452A68E9.3000707@tungstengraphics.com> <452A7AD3.5050006@yahoo.com.au>
In-Reply-To: <452A7AD3.5050006@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Thomas Hellstrom <thomas@tungstengraphics.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Your best bet might be to have a userspace "memory manager" process, which
> allocates pages (anonymous or file backed), and has your device driver
> access them with get_user_pages. The get_user_pages takes care of faulting
> the pages back in, and when they are released, the memory manager will
> swap them out on demand.

Wouldn't tmpfs be simpler ?

-- 
Who do you trust?
The people with all the right answers?
Or the people with the right questions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

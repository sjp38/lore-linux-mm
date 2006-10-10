Message-ID: <452B37D0.8000308@tungstengraphics.com>
Date: Tue, 10 Oct 2006 08:04:00 +0200
From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: Driver-driven paging?
References: <452A68E9.3000707@tungstengraphics.com> <452A7AD3.5050006@yahoo.com.au> <452A8AC6.2080203@tungstengraphics.com> <452AEDAB.5080109@yahoo.com.au>
In-Reply-To: <452AEDAB.5080109@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Thomas Hellstrom wrote:
>
>> Nick Piggin wrote:
>
>
>>> If you need for the driver to *then* export these pages out to be 
>>> mapped
>>> by other processes in userspace, I think you run into problems if 
>>> trying
>>> to use nopage. You'll need to go the nopfn route (and thus your 
>>> mappings
>>> must disallow PROT_WRITE && MAP_PRIVATE).
>>>
>>> But I think that might just work?
>>>
>> Yes, possibly. What kind of problems would I expect if using nopage? 
>> Is it, in particular, legal for a process to call get_user_pages() 
>> with the tsk and mm arguments of another process?
>
>
> Oh that is legal. What I'm thinking you'd have problems with is one
> process having its pages imported to the kernel via get_user_pages,
> then exported again via an mmap()able device node.
>
> If another process mmaps these pages, you could easily get various
> problems like PageAnon being set for a file backed page, or rmap
> structures set up incorrectly for the page. It has been a while
> since I tried to look at the details, but I would just steer clear
> of that case.
>
> Using a nopfn handler (instead of nopage) means that the kernel will
> not look at the backing pages at all.
>
Thanks. I see what you mean.

Taking into account that we may need special pages on some architectures 
to flip them into the AGP aperture, I might have to do a content copy 
anyway...

/Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 08 Jun 2000 18:29:07 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.4.21.0006082003120.22665-100000@duckman.distro.conectiva>
References: <20000608225108Z131165-245+107@kanga.kvack.org>
Subject: Re: Allocating a page of memory with a given physical address
Message-Id: <20000608235235Z131165-283+94@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Rik van Riel <riel@conectiva.com.br> on Thu, 8 Jun
2000 20:09:57 -0300 (BRST)


> Linus his policy on this is pretty strict. We won't kludge
> stuff into our kernel just to support some proprietary driver.

Well, the idea is to make it some kind of elegant enhancement that Linus would
approve of.  

My idea is to create a new API, call it alloc_phys() or get_phys_page() or
whatever, that will scan the ???? (whatever the virtual memory manager calls
those things that keep track of unused virtual memory) until it finds a block
that points to the given physical address.  It then allocates that particular
block.

Of course, from what little I know of the Linux VM, it looks like I'm in for a
rocky trip.  For one thing, I don't understand how kernel virtual memory can
have a one-to-one mapping with physical memory, but user virtual memory has to
go through three levels of page tables.  When I call get_free_page, it updates
some entry in mem_map.  What is the mechanism that updates the page tables?  I
figure the page tables need to be updated, so that a user process can't allocate
the same physical memory.


--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

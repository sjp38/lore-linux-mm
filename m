Date: Sat, 15 Sep 2001 22:51:05 -0300
From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Memory managment locks
Message-ID: <20010915225105.A2201@conectiva.com.br>
References: <3B9CBC3D.7B6509DF@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B9CBC3D.7B6509DF@scs.ch>; from maletinsky@scs.ch on Mon, Sep 10, 2001 at 03:12:29PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Em Mon, Sep 10, 2001 at 03:12:29PM +0200, Martin Maletinsky escreveu:

> I am writing a kernel thread, that should check if a process' page
> (specified by a virtual address and the pointer to a task structure) is
> present in physical memory, and if this is the case pin it in memory
> (i.e. prevent it from being swapped out). I plan to pin the page by
> incrementing it's usage count (i.e. the count field of the corresponding
> page descriptor) - this is the way map_user_kiobuf() pins pages in
> memory. I have some questions about semaphores and spinlocks to be used,
> when accessing a process' mm structure and page tables:
 
have you looked at the linux-mm wiki at http://linux-mm.org/wiki, specially
this part: http://linux-mm.org/wiki/moin.cgi/MemoryLocking ?

hope this helps,

- Arnaldo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

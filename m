Date: Tue, 27 Jun 2000 10:39:01 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.4.21.0006270323540.2591-100000@inspiron.random>
References: <20000623193609Z131187-21004+54@kanga.kvack.org>
Subject: Re: Why is the free_list not null-terminated?
Message-Id: <20000627154857Z131176-21004+69@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Andrea Arcangeli <andrea@suse.de> on Tue, 27 Jun 2000
03:27:15 +0200 (CEST)


> >Question #1: Does this mean that there are no free zones of Order 2 (16KB)?
> 
> It means there are no free contigous chunks of memory of order 2 in such
> zone.

That's what I meant :-)

> >Question #2: Why are prev and next not set to null?  Why do they point
> 
> because of linux/include/list.h ;), more seriously that avoids a path in
> the list insert/remove code but the head of the list is double size (and
> this is not an issue except for large hashtables).

Well, I don't understand what that means, but I don't think it's important. 
But something else does confuse me.

Both free_area[x].free_list.prev and free_area[x].free_list.next point to
mem_map_t blocks.  Why is that?  How do I find the head this linked list?  I
would think that free_area[x].free_list.prev would point to nothing, and
free_area[x].free_list.next points to the head of the list.

> (btw give a try also to SYSRQ+M if you are interested about similar info)

What is SYSRQ+M?  I've never heard of that!




--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

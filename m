Subject: Re: New mm and highmem reminder
References: <Pine.LNX.4.21.0010251601120.943-100000@duckman.distro.conectiva>
	<m3snpkelat.fsf@linux.local> <39F74876.29130E9B@norran.net>
From: Christoph Rohland <cr@sap.com>
Date: 26 Oct 2000 22:13:59 +0200
In-Reply-To: Roger Larsson's message of "Wed, 25 Oct 2000 22:54:14 +0200"
Message-ID: <m3n1frz7g8.fsf@linux.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Roger Larsson <roger.larsson@norran.net> writes:

> Christoph please check with Alt-SysRq-M if you have run out
> of memory in a specific zone.

SysRq: Show Memory
Mem-info:
Free pages:      5297816kB (4631308kB HighMem)
( Active: 381692, inactive_dirty: 328041, inactive_clean: 0, free: 1324431 (638 1276 1914) )
1*4kB 3*8kB 3*16kB 3*32kB 4*64kB 2*128kB 2*256kB 0*512kB 0*1024kB 6*2048kB = 13484kB)
9*4kB 4*8kB 0*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 318*2048kB = 652964kB)
1*4kB 0*8kB 0*16kB 1*32kB 0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 2261*2048kB = 4630948kB)
Swap cache: add 0, delete 0, find 0/0
Free swap:       2000052kB
2162688 pages of RAM
1867776 pages of HIGHMEM
102298 reserved pages
1275688 pages shared
0 pages swap cached
0 pages in page table cache
Buffer memory:     4860kB
    CLEAN: 612 buffers, 2448 kbyte, 1 used (last=74), 0 locked, 0 protected, 0 dirty
   LOCKED: 211501 buffers, 846004 kbyte, 22 used (last=211325), 1364 locked, 0 protected, 0 dirty
    DIRTY: 114274 buffers, 457096 kbyte, 11 used (last=114259), 0 locked, 0 protected, 114274 dirty           

> Christoph, can you put a printk in page_launder to
> see if it ever runs? (There are a lot of && conditions
> to fulfil before kflushd will start)

No, it is not run.

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

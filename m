Date: Mon, 17 Jul 2000 14:02:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
In-Reply-To: <397337EF.58667DD@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0007171401160.30603-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2000, Manfred Spraul wrote:
> Rik van Riel wrote:
> > 
> > Actually, FreeBSD has a special case in the page fault code
> > for sequential accesses and I believe we must have that too.
> 
> Where is that code?

It's in vm_fault.c, look for the readaround code.

> > Both LRU and LFU break down on linear accesses to an array
> > that doesn't fit in memory. In that case you really want
> > MRU replacement, with some simple code that "detects the
> > window size" you need to keep in memory. This seems to be
> > the only way to get any speedup on such programs when you
> > increase memory size to something which is still smaller
> > than the total program size.
> 
> Do you have an idea how to detect that situation?

I've got some ideas, but they need to be polished a bit
before I can put them into code. I'll probably do this
at OLS...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Fri, 23 Feb 2001 21:38:11 -0500 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: large mem, heavy paging issues (256M VmStk on Athlon)
In-Reply-To: <3A96C430.C028E954@amis.com>
Message-ID: <Pine.LNX.4.31.0102232136210.8568-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Whiting <ewhiting@amis.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Feb 2001, Eric Whiting wrote:

> Thanks for the info -- but I'm not sure I understand what the fix is
> to be. Does my lisp engine need to be recompiled with a newer glibc?
> Do I need to change something else?

If your lisp engine is dynamically linked to glibc, a simple
glibc upgrade should do the trick (if this thing is fixed in
newer glibcs).

> I think the strace showed the process is using mainly malloc (mmap)
> for memory allocation. I do see some brk() calls at the first. (these
> appear to be returning a 2G number not a 1G number like you suggested)

> brk(0x805a000)                          = 0x805a000

Actually, this would be 0x0805a000 if you wrote out the leading
0 ... this is more like 128 MB ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Wed, 21 Feb 2001 19:39:58 -0300 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: large mem, heavy paging issues (256M VmStk on Athlon)
In-Reply-To: <3A930E34.E24BF93E@amis.com>
Message-ID: <Pine.LNX.4.31.0102211937460.21127-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Whiting <ewhiting@amis.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Feb 2001, Eric Whiting wrote:

> I'm working with an application in Lisp. It runs on a Solaris
> box and uses about 1.3G of RAM and 9M stack before it exits
> after 2hours of running.
>
> I have been trying to run the same application on linux. It's
> memory usage hits about 1.2G and then it loses it's brain.

> This problem is either
> 1. an application problem
> 2. a linux vm/mm problem
> 3. a wacky HW problem.
> 4. ???

It's a glibc problem in combination with an oddity in the Linux
VM layer.

At 1GB, Linux starts with the mmap() areas, so brk() will only
work up to 1GB. When going over that, glibc's malloc() should
use mmap() instead to get more memory...

> What other things can I do?

> Last valid maps output (for PIII)
> -------------------------
> 08048000-0804b000 r-xp 00000000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
> 0804b000-0804d000 rw-p 00002000 00:0c 29261935   /home/pendsm1/access/bin11/linux/access
> 0804d000-0805a000 rwxp 00000000 00:00 0
> 40000000-40013000 r-xp 00000000 03:03 275293     /lib/ld-2.1.3.so
  ^^^^^^^^

Mapped at 1GB, so brk() will hit this point...

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

Date: Wed, 7 Aug 2002 12:53:57 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: memory allocation on linux
In-Reply-To: <20020807152229Z16466-21510+1725@humbolt.nl.linux.org>
Message-ID: <Pine.LNX.4.44L.0208071250110.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Cannizzaro, Emanuele" <ecannizzaro@mtc.ricardo.com>
Cc: ebiederm+eric@ccr.net, leechin@mail.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2002, Cannizzaro, Emanuele wrote:

> I am writing to you regarding your experience to address a huge amount of
> memory on linux using the brk() function.
>
> I am running a program called nastran (v2001) on a pc with redhat 7.2. This
> machine has got 2GB of disk spacebut  when I set the amount of memory to be
> used by nastran to a value bigger than 900 mb I get this fatal error message.
>
> Process Id = 28179
> idalloc: dynamic allocation failed - brk: Cannot allocate memory

The problem is that you have your libc mapped at 1GB offset
and the program executable at 128 MB, leaving about 900 MB
of space for brk().

> I have no access to the source code of the program and therefore I would
> need a patch to the memory allocation.
>
> how can this problem be fixed?

If the program is dynamically linked you could try using a
libc that uses malloc() instead of brk().

If the program uses brk, you could hack the kernel to start
mmap() at a different offset (eg 2 GB).

The easiest and arguably best option would be to link the
program statically so it doesn't have to mmap any libraries,
but it seems like you're stuck with whatever binary was given
to you so you'll have to work around the problem...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Fri, 13 Oct 2000 13:57:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0test9 vm: disappointing streaming i/o under load
In-Reply-To: <Pine.LNX.4.21.0010112341550.11841-100000@ferret.lmh.ox.ac.uk>
Message-ID: <Pine.LNX.4.21.0010131355290.10484-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Evans <chris@scary.beasts.org>
Cc: Roger Larsson <roger.larsson@norran.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Oct 2000, Chris Evans wrote:

> Perhaps I'm just asking too much, booting with mem=32M. No point
> testing the new VM with a 128Mb desktop, though; it wouldn't
> break a sweat!
> 
> 2.2 (RH7.0 kernel) does skip less, though, and the duration of
> skip is less.
> 
> Perhaps the two kernels have different elevator settings?

That too. And you just -might- be catching a boundary condition
of the drop-behind code (if the audio isn't kept mapped by any
of the processes, but is left to sit in a file which is write()n
to by one process and is read() by the other).

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

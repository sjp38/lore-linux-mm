Date: Mon, 2 Oct 2000 12:51:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM  test9-pre7
In-Reply-To: <39D87F3A.7D21E18@mountain.net>
Message-ID: <Pine.LNX.4.21.0010021250180.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0010021250182.22539@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tom Leete <tleete@mountain.net>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Tom Leete wrote:

> I ran lmbench on test9-pre7 with and without the patch.
> 
> Test machine was a slow medium memory UP box:
> Cx586@120Mhz, no optimizations, 56M
> 
> I still experience instability on this machine with both the
> patched and vanilla kernel. It usually takes the form of
> sudden total lockups, but on occasion I have seen oops +
> panic at boot.

If you could decode the oops or mail us the panic, we
might find out if this is a VM related problem or not...

> This summary doesn't show any performance advantage to the
> patch, but the detailed plots show that memory access
> latency degrades more gracefully wrt array size.

That's because this benchmark has a very artificial page
access pattern, that doesn't really benefit from any kind
of page replacement. ;)

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

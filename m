Date: Sun, 9 Jul 2000 22:53:35 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Swap clustering with new VM 
In-Reply-To: <Pine.LNX.4.21.0007091340520.14314-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0007092238450.586-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sun, 9 Jul 2000, Marcelo Tosatti wrote:

>AFAIK XFS's pagebuf structure contains a list of contiguous on-disk
>buffers, so the filesystem can do IO on a pagebuf structure avoiding disk
>seek time.
>
>Do you plan to fix the swap clustering problem with a similar idea? 

I don't know pagebuf well enough to understand if it can helps. However
I have a possible solution (not that it looks like to me that there are
many other possible solutions btw ;).

What worries me a bit is that whatever we do to improve swapin seeks it
can always disagree with what the lru says that have to be thrown away.

A dumb way to provide the current swapin-contiguous behaviour is to do a
unmap/swap-around of the pages pointed by the pagetables slots near the
one that we found in the lru.

I guess we could left a sysctl so that we can select between
swapin-optimized or lru-optimized behaviour at runtime to handy bench.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

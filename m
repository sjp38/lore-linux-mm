Date: Tue, 11 Jul 2000 15:06:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007111955100.5098-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0007111503520.10961-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Andrea Arcangeli wrote:
> On Tue, 11 Jul 2000, Rik van Riel wrote:
> >On Tue, 11 Jul 2000, Andrea Arcangeli wrote:
> >> On Tue, 11 Jul 2000, Rik van Riel wrote:
> >> 
> >> >No. You just wrote down the strongest argument in favour of one
> >> >unified queue for all types of memory usage.
> >> 
> >> Do that and download an dozen of iso image with gigabit ethernet
> >> in background.
> >
> >You need to forget about LRU for a moment. The fact that
> >LRU is fundamentally broken doesn't mean that it has
> >anything whatsoever to do with whether we age all pages
> >fairly or whether we prefer some pages over other pages.
> >
> >If LRU is broken we need to fix that, a workaround like
> >your proposal doesn't fix anything in this case.
> 
> So tell me how with your design can I avoid the kernel to unmap anything
> while running:
> 
> 	cp /dev/zero .
> 
> forever.
> 
> Whatever aging algorithm you use if you wait enough time the
> mapped pages will be thrown away eventually.

And that is correct behaviour. The problem with LRU is that the
"eventually" is too short, but proper page aging is as close to
LFU (least _frequently_ used) as it is to LRU. In that case any
page which was used only once (or was only used a long time ago)
will be freed before a page which has been used more often
recently will be.

This effectively and efficiently protects things like X, xterm
and other things which are used over and over again, while still
swapping out things which are not used at all.

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

Date: Tue, 11 Jul 2000 14:47:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007111938241.3644-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0007111445280.10961-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Andrea Arcangeli wrote:
> On Tue, 11 Jul 2000, Rik van Riel wrote:
> 
> >No. You just wrote down the strongest argument in favour of one
> >unified queue for all types of memory usage.
> 
> Do that and download an dozen of iso image with gigabit ethernet
> in background.

You need to forget about LRU for a moment. The fact that
LRU is fundamentally broken doesn't mean that it has
anything whatsoever to do with whether we age all pages
fairly or whether we prefer some pages over other pages.

If LRU is broken we need to fix that, a workaround like
your proposal doesn't fix anything in this case.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Tue, 11 Jul 2000 14:32:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007081139400.757-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0007111430470.10961-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 9 Jul 2000, Andrea Arcangeli wrote:
> On Thu, 6 Jul 2000, Stephen C. Tweedie wrote:
> 
> >> So basically we'll have these completly different lists:
> >> 
> >> 	lru_swap_cache
> >> 	lru_cache
> >> 	lru_mapped
> >> 
> >> The three caches have completly different importance that is implicit by
> >> the semantics of the memory they are queuing.
> >
> >I think this is entirely the wrong way to be thinking about the
> >problem.  It seems to me to be much more important that we know:
> 
> Think what happens if we shrink lru_mapped first. That would be
> an obviously wrong behaviour and this proof we have to consider
> a priority between lists.

No. You just wrote down the strongest argument in favour of one
unified queue for all types of memory usage.

(insert QED here)

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

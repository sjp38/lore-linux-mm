Date: Tue, 11 Jul 2000 14:45:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007111917240.3644-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0007111442150.10961-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Andrea Arcangeli wrote:
> On 11 Jul 2000, Juan J. Quintela wrote:
> 
> >I agree with Stephen here, if my cache page is older than my mmaped vi
> >page, I want to unmap first the vi page.
> 
> You said it in the other way around ;) but never mind I got your point
> indeed.
> 
> With the logic "if my cache page is younger than my mmaped vi page, I want
> to unmap first the vi page" then when you'll run:
> 
> 	cp /dev/zero .
> 
> and you'll start hanging in gnus, while switching desktop, while
> switching window, while pressing a key in bash, and indeed also
> while pressing a key in vi. For what?

This is why LRU is wrong and we need page aging (which
approximates both LRU and NFU).

The idea is to remove those pages from memory which will
not be used again for the longest time, regardless of in
which 'state' they live in main memory.

(and proper page aging is a good approximation to this)

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

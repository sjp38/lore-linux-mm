Date: Tue, 11 Jul 2000 21:32:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <yttem50mtmq.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0007112125330.5098-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On 11 Jul 2000, Juan J. Quintela wrote:

>If you are copying in the background a cp and you don't touch your
>vi/emacs/whatever pages in 2 hours (i.e. age = 0) then I think that it
>is ok for that pages to be swaped out.  Notice that the cage pages
>will have _initial age_  and the pages of the binaries will have an
>_older_ age.

If we want to do that we can do that. My design doesn't forbid this. I
only avoid the overhead of the inactive list.

Also note that what I was really complaining is to threat the lru_cached
and lru_mapped list equally. If you threat them equally you get in
troubles as I pointed out. I just want to say that lru_mapped have much
more priority than lru_cache. If you give the higher priority with a aging
factor, or I give higher priority with a different falling back behaviour
it doesn't matter (with the difference that I avoid overhead of refiling
between lru lists and I avoid to roll ex-mapped-pages in the lru_cache
list just to decrease their age).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

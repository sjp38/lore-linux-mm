Message-ID: <39648F97.2ABB2F71@augan.com>
Date: Thu, 06 Jul 2000 15:54:31 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on2.4.0-test2
References: <Pine.LNX.4.21.0007061211480.4810-100000@inspiron.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

Andrea Arcangeli wrote:

> So basically we'll have these completly different lists:
> 
>         lru_swap_cache
>         lru_cache
>         lru_mapped
> 
> The three caches have completly different importance that is implicit by
> the semantics of the memory they are queuing. Shrinking swap_cache first
> is vital for performance under swap for example (and I can just do that in
> recent classzone patches). Shrinking lru_cache first is vital for
> performance under streaming I/O but without low on freeable memory
> scenario.

How do you want to synchronize and balance these caches? Do you expect
that these are never used at the same time? What happens with disk
blocks that end up in different caches?
IMO the problem gets worse, if we want better direct i/o support
especially on systems where fs block size is different from page size.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Wed, 12 Jul 2000 02:52:26 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <396bb43f.25232236@mail.mbay.net>
Message-ID: <Pine.LNX.4.21.0007120247120.8571-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Alvord <jalvo@mbay.net>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jul 2000, John Alvord wrote:

>One question that puzzles me... cache for disk files and cache for
>program data will have very unlike characteristics. Executable program

Agreed. That is exactly what I'm trying say by telling that lru_cache and
lru_mapped_cache have different implicit priorities and we can't threat
them in the same way.

>enough, what algorithm is used to achieve an effective balance of
>usage?

In 2.[234].x we basically first try to shrink the cache for disk and when
we run low in cache for disk (so when we start to fail in shrinking it) we
fallback shrinking the cache for program. That's sane algorithm even if
currently it's not very smart in understanding when it's time to shrink
the cache for programs and it's also not able to shrink it properly in
some case.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

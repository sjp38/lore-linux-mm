Date: Tue, 11 Jul 2000 19:54:31 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <Pine.LNX.4.21.0007111442150.10961-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0007111944450.3644-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Rik van Riel wrote:

>This is why LRU is wrong and we need page aging (which
>approximates both LRU and NFU).
>
>The idea is to remove those pages from memory which will
>not be used again for the longest time, regardless of in
>which 'state' they live in main memory.
>
>(and proper page aging is a good approximation to this)

It will still drop _all_ VM mappings from memory if you left "cp /dev/zero
." in background for say 2 hours. This in turn mean that during streming
I/O you'll have _much_ more than the current swapin/swapout troubles.

If I download a dozen of CD images with a gigabit ethernet I don't want
_anything_ to be unmapped from main RAM, and yes I may have 8giga of RAM
so I don't want to use O_DIRECT for the downloads.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

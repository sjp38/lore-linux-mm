From: Alan Cox <alan@redhat.com>
Message-Id: <200007171446.KAA07554@devserv.devel.redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Date: Mon, 17 Jul 2000 10:46:11 -0400 (EDT)
In-Reply-To: <200007170709.DAA27512@ocelot.cc.gatech.edu> from "Yannis Smaragdakis" at Jul 17, 2000 03:09:06 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yannis Smaragdakis <yannis@cc.gatech.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Both will cause exactly one page fault. Also, one should be cautious of
> pages that are brought in RAM, touched many times, but then stay untouched
> for a long time. Frequency should never outweigh recency--the latter is
> a better predictor, as OS designers have found since the early 70s.

Modern OS designers are consistently seeing LFU work better. In our case this
is partly theory in the FreeBSD case its proven by trying it.

> pages we recently evicted), we adapt it by evicting more recently 
> touched pages (sounds hacky, but it is actually very clean).
> 
> The results are very good (even better than in the paper, as we have
> improved the algorithm since).

Interesting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

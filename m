Date: Wed, 3 May 2000 03:28:16 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
In-Reply-To: <Pine.LNX.4.10.10005021743270.811-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005030323220.4537-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Linus Torvalds wrote:

>Note that as far as I remember, the swap entry thing was introduced
>because get_swap_entry() was slow and took up a lot of time.

That's a good point too but I was more worried about I/O seek time than CPU
load.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

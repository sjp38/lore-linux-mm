Date: Fri, 12 May 2000 21:40:52 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121200590.4959-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005122139340.6188-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

note that now i'm running the 4GB variant of highmem (easier to fill up) -
so the physical memory layout goes like this:

	1GB permanently mapped RAM
	~2GB highmem

(only 2GB highmem because 5GB of RAM is above 4GB, so unaccesible to
normal 32-bit PTEs.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

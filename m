Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Date: Mon, 9 Oct 2000 22:51:34 +0100 (BST)
In-Reply-To: <Pine.LNX.4.10.10010091435420.1438-100000@penguin.transmeta.com> from "Linus Torvalds" at Oct 09, 2000 02:38:10 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13ikpc-0002uZ-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > across AF_UNIX sockets so the mechanism is notionally there to provide the 
> > credentials to X, just not to use them
> 
> The problem is that there is no way to keep track of them afterwards.

If you use mmap for your allocator then beancounter will get it right. Every
resource knows which beancounter it was charged too. It adds an overhead the
average desktop user won't like but which is pretty much essential to do real
mainframe world operation. So it would become

	seteuid(Client->passed_euid);
	mmap(buffer in pages)
	seteuid(getuid());

With lightwait counting semantics its hard to make any tracking system work
well in the corner cases like resources that survive process death.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 25 Sep 2000 12:13:08 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925033128.A10381@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251207590.1459-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> Not sure if this is the right moment for those changes though, I'm not
> worried about ext2 but about the other non-netoworked fses that nobody
> uses regularly.

it *is* the right moment to clean these issues up. These kinds of things
are what made the 2.2 VM a mess (everybody added his easy improvements,
without solving some of the conceptual problems), and frankly, instead of
yet another elevator algorithm we need a squeaky clean VM balancer above
all. Please help identifying, fixing, debugging and testing these VM
balancing issues. This is tough work and it needs to be done.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

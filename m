Date: Fri, 19 Jan 2001 12:49:38 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.10.10101182307340.9418-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.30.0101191247210.1137-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jan 2001, Linus Torvalds wrote:

> Whatever. Maybe it can be done other ways. The fact that the way I
> thought to implement it was with an order-2 allocation to do this
> efficiently is what really killed it for me. [...]

it can be done by 'implicitly' linking the soft and hard table via putting
it on the same 8K-aligned order-2 page, but linking them through their
mem_map[] entries. The fields of mem_map[] entries of ordinary pagetables
are largely unused, they are privately allocated pages.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

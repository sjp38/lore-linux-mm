Date: Sun, 14 May 2000 12:55:03 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.10.10005141245510.1494-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005141253460.1494-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 May 2000, Ingo Molnar wrote:

> a __free_pages variant that does not increase zone->free_pages. this is
> then later on done by the allocator (ie. __alloc_pages). This 'free page
> transport' mechanizm guarantees that the non-atomic allocation path does
> not 'lose' free pages along the way.

'normal' (non- __alloc_pages()-driven) __free_pages() still increases
zone->free_pages just like before.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Mon, 15 May 2000 21:22:12 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] VM stable again?
In-Reply-To: <20000515200116.E24812@redhat.com>
Message-ID: <Pine.LNX.4.10.10005152120350.8896-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Stephen C. Tweedie wrote:

> One other thought here --- there is another way to achieve this.
> Make try_to_free_pages() return a struct page *.  That will not
> only achieve some measure of SMP locality, it also guarantees that
> the page freed will be reacquired by the task which did the work to
> free it.

i suggested this as well, but this is not always possible. Eg. the dentry
and inode cache does a slab-free, and there is no good (existing)
mechanizm to do it and recover the page freed. And singling out
shrink_mmap() is not generic enough. (although it's the most common source
of free pages)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

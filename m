Date: Mon, 25 Sep 2000 16:35:44 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: refill_inactive()
In-Reply-To: <Pine.LNX.4.21.0009251102420.14614-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0009251631020.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Roger Larsson <roger.larsson@norran.net>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Rik van Riel wrote:

> 2) you are right, we /can/ schedule when __GFP_IO isn't set, this is
>    mistake ... now I'm getting confused about what __GFP_IO is all
>    about, does anybody know the _exact_ meaning of __GFP_IO ?

__GFP_IO set to 1 means that the allocator can afford doing IO implicitly
by the page allocator. Most allocations dont care at all wether swap IO is
started as part of gfp() or not. But a prominent counter-example is
GFP_BUFFER, which is used by the buffer-cache/fs layer, and which cannot
do any IO implicitly. (because it *is* the IO layer already, and it is
already trying to do IO.) The other reason are legacy lowlevel-filesystem
locks like the ext2fs lock, which cannot be taken recursively.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

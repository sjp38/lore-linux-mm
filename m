From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14185.33779.162152.95290@dukat.scot.redhat.com>
Date: Fri, 18 Jun 1999 00:25:39 +0100 (BST)
Subject: Re: process selection
In-Reply-To: <4.1.19990615122732.00942160@box4.tin.it>
References: <4.1.19990615122732.00942160@box4.tin.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Antonino Sabetta <copernico@tin.it>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 1999 12:28:06 +0200, Antonino Sabetta <copernico@tin.it> said:

>> 2. Also, in swap_out, it might make sense to steal more than a
>> single page from a victim process, to balance the overhead of
>> scanning all the processes.

> Or at least, steal more that a single page if the process owns a "big"
> number of pages.

This is something we really, really need to do eventually, to reduce the
overhead of the swapper.  Optimisations such as unmapping large chunks
at once for sequentially accessed mmap()s are an example of obvious
performance improvements, but by swapping multiple pages we also have
opportunities for reducing swap fragmentation.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

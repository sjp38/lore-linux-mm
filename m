Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
Date: Mon, 25 Sep 2000 00:20:14 +0100 (BST)
In-Reply-To: <20000924223814.B2615@redhat.com> from "Stephen C. Tweedie" at Sep 24, 2000 10:38:14 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dL4C-0004UM-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> quota drop, and that involves quota writeback if it was the last inode
> on that particular quota struct.
> 
> shrinking the icache _usually_ involves no IO, but the quota case is
> an exception which a lot of developers won't encounter during testing.

We've had a history of weird quota deadlocks in 2.0 and earlier 2.2. Is there
a reason quota block writeback cannot be queued or handled by a thread ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

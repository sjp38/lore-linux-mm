Date: Sun, 24 Sep 2000 21:27:39 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000925033128.A10381@athlon.random>
Message-ID: <Pine.GSO.4.21.0009242122520.14096-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> I'm thinking that dropping the superblock lock completly wouldn't be much more
> difficult than this mid stage.  The only cases where we block in critical
> sections protected by the superblock lock is in getblk/bread (bread calls
> getblk) and ll_rw_block and mark_buffer_dirty.  Once we drop the lock for the
> first cases it should not be more difficult to drop it completly.

ext2_new_block->dquot_alloc_block->lock_dquot

ext2_new_block->dquot_alloc_block->check_bdq->print_warning->tty_write_message


> Not sure if this is the right moment for those changes though, I'm not worried
> about ext2 but about the other non-netoworked fses that nobody uses regularly.

So help testing the patches to them. Arrgh...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Sun, 24 Sep 2000 23:12:40 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000924231240.D5571@athlon.random>
References: <20000924222431.C5571@athlon.random> <Pine.LNX.4.21.0009242225300.8705-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242225300.8705-100000@elte.hu>; from mingo@elte.hu on Sun, Sep 24, 2000 at 10:26:11PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 10:26:11PM +0200, Ingo Molnar wrote:
> where will it deadlock?

ext2_new_block (or whatever that runs getblk with the superlock lock acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Sun, 24 Sep 2000 23:12:39 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000924231240.D5571@athlon.random>
Message-ID: <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Andrea Arcangeli wrote:

> ext2_new_block (or whatever that runs getblk with the superlock lock
> acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->
> prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->
> put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D

nasty indeed, sigh. Shouldnt ext2_new_block drop the superblock lock in
places where we might block?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

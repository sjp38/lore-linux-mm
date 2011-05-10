Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 74BFB6B0030
	for <linux-mm@kvack.org>; Tue, 10 May 2011 12:25:29 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
In-reply-to: <20110510125124.GD4402@quack.suse.cz>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com> <20110510125124.GD4402@quack.suse.cz>
Date: Tue, 10 May 2011 12:24:50 -0400
Message-Id: <1305044672-sup-6072@shiny>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>

Excerpts from Jan Kara's message of 2011-05-10 08:51:24 -0400:
> On Mon 09-05-11 16:03:18, Darrick J. Wong wrote:
> > I am still chasing down what exactly is broken in ext3.  data=writeback mode
> > passes with no failures.  data=ordered, however, does not pass; my current
> > suspicion is that jbd is calling submit_bh on data buffers but doesn't call
> > page_mkclean to kick the userspace programs off the page before writing it.
>   Yes, ext3 in data=ordered mode writes pages from
> journal_commit_transaction() via submit_bh() without clearing page dirty
> bits thus page_mkclean() is not called for these pages. Frankly, do you
> really want to bother with adding support for ext2 and ext3? People can use
> ext4 as a fs driver when they want to start using blk-integrity support.
> Especially ext2 patch looks really painful and just from a quick look I can
> see code e.g. in fs/ext2/namei.c which isn't handled by your patch yet.

I think ext23 are going to be pretty big changes, we're best off just
going with ext4.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

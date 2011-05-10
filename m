Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 766E090011B
	for <linux-mm@kvack.org>; Tue, 10 May 2011 13:03:54 -0400 (EDT)
Date: Tue, 10 May 2011 13:03:39 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510170339.GA27538@infradead.org>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <87tyd31fkc.fsf@devron.myhome.or.jp>
 <20110510133603.GA5823@infradead.org>
 <874o524q9h.fsf@devron.myhome.or.jp>
 <20110510144939.GI4402@quack.suse.cz>
 <87aaeur31x.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87aaeur31x.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Wed, May 11, 2011 at 12:24:58AM +0900, OGAWA Hirofumi wrote:
> > under writeback and when it's freed no writeback is started.
> 
> Sure for data -> data reallocated case. metadata -> data/metadata is
> still there.

That's usually handled differently.  For XFS take a look at the
xfs_alloc_busy_* function.  For 2.6.40 they've been mostly rewritten
to rarely wait for the reuse but instead avoid busy blocks.  But that's
a real data integrity issue even without stable pages for I/O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

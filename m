Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8196090010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:36:23 -0400 (EDT)
Date: Tue, 10 May 2011 09:36:03 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110510133603.GA5823@infradead.org>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <87tyd31fkc.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87tyd31fkc.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Tue, May 10, 2011 at 10:59:15AM +0900, OGAWA Hirofumi wrote:
> I'd like to know those patches are on what state. Waiting in writeback
> page makes slower, like you mentioned it (I guess it would more
> noticeable if device was slower that like FAT uses). And I think
> currently it doesn't help anything others for blk-integrity stuff
> (without other technic, it doesn't help FS consistency)?

It only makes things slower if we rewrite a region in a file that
is currently undergoing writeback.  I'd be interested to know about
real life applications doing that, and if they really are badly affect
we should help them to work around that in userspace, e.g. by adding
a fadvice will rewrite call that might be used to never write back
that regions without an explicit fsync call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

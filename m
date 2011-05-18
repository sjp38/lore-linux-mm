Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A605D6B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:17:37 -0400 (EDT)
Date: Wed, 18 May 2011 14:17:11 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [5/7] ext4: Wait for writeback to complete while making pages
 writable
Message-ID: <20110518181711.GB13693@thunk.org>
References: <20110509230356.19566.48351.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509230356.19566.48351.stgit@elm3c44.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Mon, May 09, 2011 at 01:03:56PM -0000, Darrick J. Wong wrote:
> In order to stabilize pages during disk writes, ext4_page_mkwrite must wait for
> writeback operations to complete before making a page writable.  Furthermore,
> the function must return locked pages, and recheck the writeback status if the
> page lock is ever dropped.  The "someone could wander in" part of this patch
> was suggested by Chris Mason.
> 
> Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
> 
> ---
> fs/ext4/inode.c |   24 +++++++++++++++++++-----
>  1 files changed, 19 insertions(+), 5 deletions(-)

Added to the ext4 tree, thanks.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

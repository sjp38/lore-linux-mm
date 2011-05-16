Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D76A1900118
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:56:32 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GKohV4006662
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:50:43 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GKtbmh259502
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:56:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GEtZeU022691
	for <linux-mm@kvack.org>; Mon, 16 May 2011 08:55:37 -0600
Date: Mon, 16 May 2011 13:55:35 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
	writeback for various fses
Message-ID: <20110516205535.GP20579@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com> <20110516190427.GN20579@tux1.beaverton.ibm.com> <20110516202710.GA32630@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110516202710.GA32630@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Mon, May 16, 2011 at 04:27:10PM -0400, Christoph Hellwig wrote:
> Whay about just sending the VFS patches to Al

Al was in the To: list of all 7 patches.

> instead of talking about it on a totally irrelevant call that doesn't include
> the important stakeholders?  FS-specific patches can go through the fs
> maintainers independently.

The maintainers (ext4/ext2/vfat) were also in the To: list.

Trouble is, MAINTAINERS says this:

MEMORY MANAGEMENT
L:      linux-mm@kvack.org
W:      http://www.linux-mm.org
S:      Maintained
F:      include/linux/mm.h
F:      mm/

There's a list, but no specific contact person.  That's why I had to start
asking around about who actually pushes mm changes to Linus.

As for Al Viro, he's still listed as the VFS maintainer; isn't he resting?
I guess he did nominate you for the holding off of morons (like me). :)

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

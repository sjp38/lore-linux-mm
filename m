Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BB88D6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:20:49 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4RG47oJ029153
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:04:07 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RGKQnR070690
	for <linux-mm@kvack.org>; Fri, 27 May 2011 10:20:30 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RAK2HN031039
	for <linux-mm@kvack.org>; Fri, 27 May 2011 04:20:05 -0600
Date: Fri, 27 May 2011 09:20:00 -0700
From: "Darrick J. Wong" <djwong@us.ibm.com>
Subject: Re: [PATCHSET v3.2 0/3] data integrity: Stabilize pages during
	writeback for various fses
Message-ID: <20110527162000.GV18929@tux1.beaverton.ibm.com>
Reply-To: djwong@us.ibm.com
References: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com> <20110527073326.GA15405@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110527073326.GA15405@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Theodore Tso <tytso@mit.edu>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Fri, May 27, 2011 at 03:33:26AM -0400, Christoph Hellwig wrote:
> Can you resend patches 1 and 2 ontop of current Linus' tree with Jans
> page_mkwrite changes?  I don't think there's much point of patch 3 until
> we get a user for simple_page_mkwrite.

Sure thing.  I'll have something ready by the afternoon (here).

--D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

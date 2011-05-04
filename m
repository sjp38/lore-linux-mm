Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 84A2E6B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 14:47:11 -0400 (EDT)
Date: Wed, 4 May 2011 14:46:44 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 0/3] data integrity: Stabilize pages during writeback
 for ext4
Message-ID: <20110504184644.GA23246@infradead.org>
References: <20110406232938.GF1110@tux1.beaverton.ibm.com>
 <20110407165700.GB7363@quack.suse.cz>
 <20110408203135.GH1110@tux1.beaverton.ibm.com>
 <20110411124229.47bc28f6@corrin.poochiereds.net>
 <1302543595-sup-4352@think>
 <1302569212.2580.13.camel@mingming-laptop>
 <20110412005719.GA23077@infradead.org>
 <1302742128.2586.274.camel@mingming-laptop>
 <20110422000226.GA22189@tux1.beaverton.ibm.com>
 <20110504173704.GE20579@tux1.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110504173704.GE20579@tux1.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jeff Layton <jlayton@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Joel Becker <jlbec@evilplan.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jens Axboe <axboe@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Mingming Cao <mcao@us.ibm.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

This seems to miss out on a lot of the generic functionality like
write_cache_pages and block_page_mkwrite and just patch it into
the ext4 copy & paste variants.  Please make sure your patches also
work for filesystem that use more of the generic functionality like
xfs or ext2 (the latter one might be fun for the mmap case).

Also what's the status of btrfs?  I remembered there was one or two
bits missing despite doing the right thing in most areas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

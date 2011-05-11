Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6816B0011
	for <linux-mm@kvack.org>; Wed, 11 May 2011 01:55:50 -0400 (EDT)
Date: Wed, 11 May 2011 01:55:09 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during
 writeback for various fses
Message-ID: <20110511055509.GA4886@infradead.org>
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
 <87tyd31fkc.fsf@devron.myhome.or.jp>
 <20110510133603.GA5823@infradead.org>
 <874o524q9h.fsf@devron.myhome.or.jp>
 <20110510144939.GI4402@quack.suse.cz>
 <87aaeur31x.fsf@devron.myhome.or.jp>
 <20110510170339.GA27538@infradead.org>
 <87liyep9fk.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87liyep9fk.fsf@devron.myhome.or.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

On Wed, May 11, 2011 at 05:50:07AM +0900, OGAWA Hirofumi wrote:
> Sounds good. So... Are you suggesting this series should use better
> approach than just blocking?

No, block reuse is a problem independent of stable pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

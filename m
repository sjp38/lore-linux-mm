Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 94C7C90010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:52:15 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
	<87tyd31fkc.fsf@devron.myhome.or.jp>
	<20110510133603.GA5823@infradead.org>
Date: Tue, 10 May 2011 22:52:10 +0900
In-Reply-To: <20110510133603.GA5823@infradead.org> (Christoph Hellwig's
	message of "Tue, 10 May 2011 09:36:03 -0400")
Message-ID: <874o524q9h.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

Christoph Hellwig <hch@infradead.org> writes:

> On Tue, May 10, 2011 at 10:59:15AM +0900, OGAWA Hirofumi wrote:
>> I'd like to know those patches are on what state. Waiting in writeback
>> page makes slower, like you mentioned it (I guess it would more
>> noticeable if device was slower that like FAT uses). And I think
>> currently it doesn't help anything others for blk-integrity stuff
>> (without other technic, it doesn't help FS consistency)?
>
> It only makes things slower if we rewrite a region in a file that is
> currently undergoing writeback. I'd be interested to know about real
> life applications doing that, and if they really are badly affect we
> should help them to work around that in userspace, e.g. by adding a
> fadvice will rewrite call that might be used to never write back that
> regions without an explicit fsync call.

Isn't it reallocated blocks too, and metadata too?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

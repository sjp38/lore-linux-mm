Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 59A2890010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:46:22 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
	<87tyd31fkc.fsf@devron.myhome.or.jp>
	<20110510123819.GB4402@quack.suse.cz>
	<87hb924s2x.fsf@devron.myhome.or.jp>
	<20110510132953.GE4402@quack.suse.cz>
Date: Tue, 10 May 2011 22:46:16 +0900
In-Reply-To: <20110510132953.GE4402@quack.suse.cz> (Jan Kara's message of
	"Tue, 10 May 2011 15:29:53 +0200")
Message-ID: <878vue4qjb.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

Jan Kara <jack@suse.cz> writes:

>> I see. So many block layer stuff sounds like broken on corner case? If
>> so, I more feel this approach should be temporary workaround, and should
>> use another less-blocking approach.
>   Not many but some... The alternative to less blocking approach is to do
> copy-out before a page is submitted for IO (or various middle ground
> alternatives of doing sometimes copyout, sometimes blocking...). That costs
> some performance as well. We talked about it at LSF and the approach
> Darrick is implementing was considered the least intrusive. There's really
> no way to fix these corner cases and keep performance.

You already considered, to copy only if page was writeback (like
copy-on-write). I.e. if page is on I/O, copy, then switch the page for
writing new data.

Yes, it is complex. But I think blocking and overhead is minimum, and
this can be used as infrastructure for copy-on-write FS.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

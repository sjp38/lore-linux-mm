Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D80246B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 05:37:05 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
	<87tyd31fkc.fsf@devron.myhome.or.jp>
	<20110510133603.GA5823@infradead.org>
	<874o524q9h.fsf@devron.myhome.or.jp>
	<20110510144939.GI4402@quack.suse.cz>
	<87aaeur31x.fsf@devron.myhome.or.jp>
	<20110510170339.GA27538@infradead.org>
	<87liyep9fk.fsf@devron.myhome.or.jp>
	<20110511055509.GA4886@infradead.org>
Date: Wed, 11 May 2011 18:36:53 +0900
In-Reply-To: <20110511055509.GA4886@infradead.org> (Christoph Hellwig's
	message of "Wed, 11 May 2011 01:55:09 -0400")
Message-ID: <877h9xpoi2.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

Christoph Hellwig <hch@infradead.org> writes:

> On Wed, May 11, 2011 at 05:50:07AM +0900, OGAWA Hirofumi wrote:
>> Sounds good. So... Are you suggesting this series should use better
>> approach than just blocking?
>
> No, block reuse is a problem independent of stable pages.

OK. So, sounds like we are talking different points. I was generic stuff
(whole of patches). You were only some patches (guess it's only data page).
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A8EDF6B0023
	for <linux-mm@kvack.org>; Tue, 10 May 2011 09:13:06 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCHSET v3.1 0/7] data integrity: Stabilize pages during writeback for various fses
References: <20110509230318.19566.66202.stgit@elm3c44.beaverton.ibm.com>
	<87tyd31fkc.fsf@devron.myhome.or.jp>
	<20110510123819.GB4402@quack.suse.cz>
Date: Tue, 10 May 2011 22:12:54 +0900
In-Reply-To: <20110510123819.GB4402@quack.suse.cz> (Jan Kara's message of
	"Tue, 10 May 2011 14:38:19 +0200")
Message-ID: <87hb924s2x.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Darrick J. Wong" <djwong@us.ibm.com>, Theodore Tso <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

Jan Kara <jack@suse.cz> writes:

>> I'd like to know those patches are on what state. Waiting in writeback
>> page makes slower, like you mentioned it (I guess it would more
>> noticeable if device was slower that like FAT uses). And I think
>> currently it doesn't help anything others for blk-integrity stuff
>> (without other technic, it doesn't help FS consistency)?
>> 
>> So, why is this locking stuff enabled always? I think it would be better
>> to enable only if blk-integrity stuff was enabled.
>> 
>> If it was more sophisticate but more complex stuff (e.g. use
>> copy-on-write technic for it), I would agree always enable though.
>   Well, also software RAID generally needs this feature (so that parity
> information / mirror can be properly kept in sync). Not that I'd advocate
> that this feature must be always enabled, it's just that there are also
> other users besides blk-integrity.

I see. So many block layer stuff sounds like broken on corner case? If
so, I more feel this approach should be temporary workaround, and should
use another less-blocking approach.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from ibmpc.myhome.or.jp ([210.171.168.39]:3754)
	by parknet.jp with [XMail 1.21 ESMTP Server]
	id <SD441> for <linux-mm@kvack.org> from <hirofumi@mail.parknet.co.jp>;
	Tue, 12 Dec 2006 03:18:47 +0900
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au>
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Tue, 12 Dec 2006 03:17:19 +0900
In-Reply-To: <45751712.80301@yahoo.com.au> (Nick Piggin's message of "Tue\, 05 Dec 2006 17\:52\:02 +1100")
Message-ID: <878xhewb4g.fsf@duaron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> Finally, filesystems. Only OGAWA Hirofumi and Mark Fasheh have given much
> feedback so far. I've tried to grok ext2/3 and think they'll work OK, and
> have at least *looked* at all the rest. However in the worst case, there
> might be many subtle and different problems :( Filesystem developers need
> to review this, please. I don't want to cc every filesystem dev list, but
> if anybody thinks it would be helpful to forward this then please do.

BTW, there are still some from==to users.

	fs/affs/file.c:affs_truncate
	fs/hfs/extent.c:hfs_file_truncate
	fs/hfsplus/extents.c:hfsplus_file_truncate
	fs/reiserfs/ioctl.c:reiserfs_unpack

I'll see those this weekend.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

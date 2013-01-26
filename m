Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 84EFF6B0010
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 07:39:47 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id v28so633257qcm.11
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 04:39:46 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Sat, 26 Jan 2013 13:39:46 +0100
Message-ID: <CA+icZUXsi0jZZE9HBWG0D6-+oJBeX+8nHpZ9F02x=B7dG3X+yg@mail.gmail.com>
Subject: Re: block: optionally snapshot page contents to provide stable pages
 during write
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>

Hi Darrick,

can you tell me why you do not put your help text where it normally
belongs ("help" Kconfig item)?

273 # We also use the bounce pool to provide stable page writes for jbd.  jbd
274 # initiates buffer writeback without locking the page or setting
PG_writeback,
275 # and fixing that behavior (a second time; jbd2 doesn't have this
problem) is
276 # a major rework effort.  Instead, use the bounce buffer to snapshot pages
277 # (until jbd goes away).  The only jbd user is ext3.
278 config NEED_BOUNCE_POOL
279         bool
280         default y if (TILE && USB_OHCI_HCD) || (BLK_DEV_INTEGRITY && JBD)
281         help
282         line #273..277

Noticed while hunting a culprit commit in Linux-Next as my
kernel-config got changed between next-20130123..next-20130124.

Regards,
- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=3f1c22e#patch5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

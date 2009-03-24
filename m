Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 06E956B005C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 15:57:58 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	<20090324125510.GA9434@duck.suse.cz>
	<20090324132637.GA14607@duck.suse.cz>
	<200903250130.02485.nickpiggin@yahoo.com.au>
	<20090324144709.GF23439@duck.suse.cz>
	<1237906563.24918.184.camel@twins>
	<20090324152959.GG23439@duck.suse.cz>
Date: Wed, 25 Mar 2009 05:14:34 +0900
In-Reply-To: <20090324152959.GG23439@duck.suse.cz> (Jan Kara's message of
	"Tue, 24 Mar 2009 16:29:59 +0100")
Message-ID: <873ad2znit.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

Jan Kara <jack@suse.cz> writes:

>   BTW: Note that there's a plenty of filesystems that don't implement
> mkwrite() (e.g. ext2, UDF, VFAT...) and thus have the same problem with
> ENOSPC. So I'd not speak too much about consistency ;).

FWIW, fatfs doesn't allow sparse file (mmap the non-allocated region),
so I guess there is no problem.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

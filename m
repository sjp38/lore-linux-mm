Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA22852
	for <linux-mm@kvack.org>; Mon, 24 May 1999 11:46:34 -0400
Date: Mon, 24 May 1999 16:55:27 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] depricate ZMAGIC binaries
In-Reply-To: <m1btfbsk67.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.4.05.9905241654130.2102-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 23 May 1999, Eric W. Biederman wrote:

>diff -uNrX linux-ignore-files linux-2.3.3.eb1/mm/filemap.c linux-2.3.3.eb2/mm/filemap.c
>--- linux-2.3.3.eb1/mm/filemap.c	Tue May 18 01:11:52 1999
>+++ linux-2.3.3.eb2/mm/filemap.c	Tue May 18 01:12:47 1999
>@@ -1319,8 +1319,7 @@
> 			return -EINVAL;
> 	} else {
> 		ops = &file_private_mmap;
>-		if (inode->i_op && inode->i_op->bmap &&
>-		    (vma->vm_offset & (inode->i_sb->s_blocksize - 1)))
>+		if (vma->vm_offset & (PAGE_SIZE -1))
> 			return -EINVAL;

Minor issue: since now there is no difference in the align check between
VM_SHARED and VM_PRIVATE you can check the alignment in a common path.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

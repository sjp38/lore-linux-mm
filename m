Subject: Re: 2.6.0-test5-mm1
From: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <20030908235028.7dbd321b.akpm@osdl.org>
References: <20030908235028.7dbd321b.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1063093989.12321.28.camel@ixodes.goop.org>
Mime-Version: 1.0
Date: Tue, 09 Sep 2003 00:53:09 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-09-08 at 23:50, Andrew Morton wrote:
> +group_leader-rework.patch
> 
>  Use the thread group leader's pgrp rather than the current thread's pgrp
>  everywhere.

Missed one:

 fs/autofs/inode.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/autofs/inode.c~fix-pgrp fs/autofs/inode.c
--- local-2.6/fs/autofs/inode.c~fix-pgrp	2003-09-09 00:29:35.000000000 -0700
+++ local-2.6-jeremy/fs/autofs/inode.c	2003-09-09 00:30:05.000000000 -0700
@@ -129,7 +129,7 @@ int autofs_fill_super(struct super_block
 	sbi->magic = AUTOFS_SBI_MAGIC;
 	sbi->catatonic = 0;
 	sbi->exp_timeout = 0;
-	sbi->oz_pgrp = current->pgrp;
+	sbi->oz_pgrp = process_group(current);
 	autofs_initialize_hash(&sbi->dirhash);
 	sbi->queues = NULL;
 	memset(sbi->symlink_bitmap, 0, sizeof(long)*AUTOFS_SYMLINK_BITMAP_LEN);

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Message-Id: <20080621154722.879182964@szeredi.hu>
References: <20080621154607.154640724@szeredi.hu>
Date: Sat, 21 Jun 2008 17:46:08 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [rfc patch 1/4] splice: fix comment
Content-Disposition: inline; filename=splice_fix_comment.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Clearing SPLICE_F_NONBLOCK means: block.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/splice.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-06-19 14:58:10.000000000 +0200
+++ linux-2.6/fs/splice.c	2008-06-20 13:12:37.000000000 +0200
@@ -978,7 +978,7 @@ ssize_t splice_direct_to_actor(struct fi
 	flags = sd->flags;
 
 	/*
-	 * Don't block on output, we have to drain the direct pipe.
+	 * Block on output, we have to drain the direct pipe.
 	 */
 	sd->flags &= ~SPLICE_F_NONBLOCK;
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

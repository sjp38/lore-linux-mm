Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BC8FD6B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:02:45 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6125698pbb.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:02:45 -0700 (PDT)
Date: Sat, 12 May 2012 05:02:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/10] tmpfs: enable NOSEC optimization
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120500040.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Let tmpfs into the NOSEC optimization (avoiding file_remove_suid()
overhead on most common writes): set MS_NOSEC on its superblocks.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |    1 +
 1 file changed, 1 insertion(+)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:45:17.888060878 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:46:05.732062006 -0700
@@ -2361,6 +2361,7 @@ int shmem_fill_super(struct super_block
 		}
 	}
 	sb->s_export_op = &shmem_export_ops;
+	sb->s_flags |= MS_NOSEC;
 #else
 	sb->s_flags |= MS_NOUSER;
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

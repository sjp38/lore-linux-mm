Message-Id: <20080318185626.300130296@szeredi.hu>
Date: Tue, 18 Mar 2008 19:56:26 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/4] fuse: writable mmap fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here are the requested fixes as incremental patches.  Also
mm-allow-not-updating-bdi-stats-in-end_page_writeback.patch is no
longer needed.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

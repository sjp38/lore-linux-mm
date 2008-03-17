Message-Id: <20080317191908.123631326@szeredi.hu>
Date: Mon, 17 Mar 2008 20:19:08 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/8] fuse: writable mmap + batched write
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

These are fuse updates for 2.6.26.

1-4) small tweaks to core code to make writable mmap in fuse possible
5) the fuse writable mmap support itself
6-7) allows buffered fuse writes to be bigger than 4k
8) handle short buffered reads better

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

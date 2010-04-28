Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 839396B01F2
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:13 -0400 (EDT)
Message-Id: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:36 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 0/6] fuse: implement zero copy read
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This series implements splice(2) to the fuse device.  With this it's
possible to move pages directly into the page cache of the fuse
filesystem without ever having to copy the contents.

The next series will implement splicing from the fuse device for zero
copy write operations.

Testing shows improved bandwidth and reduced system time (as
expected).  However there's still some overhead in shuffling pages
between caches.  Further improvements could be achieved by

 - implementing replace_page_cache_page() which atomically removes an
   old page and replaces it with a new one

 - implementing splice a-la O_DIRECT which, instead of populating the
   page cache, would just send/receive data directly in pipe buffers.

Comments?

Thanks,
Miklos
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

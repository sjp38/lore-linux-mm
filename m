Message-Id: <20080625124038.103406301@szeredi.hu>
Date: Wed, 25 Jun 2008 14:40:38 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/2] splice: fix nfs export of fuse filesystems
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Well, it wasn't that hard to fix just this issue.  I tested the
following two patches, and verified that splice-in and splice-out now
always return full counts, even if pages are invalidated during the
splicing.

The ClearPageUptodate() thing in 1/2 needs a bit of careful attention
from VM hackers (Hugh and Nick added to CC).

I still see small issues with generic_file_splice_read() (more in a
separate email) and I don't quite see how this async thing is going to
work out, but that's another story.

Thanks,
Miklos
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

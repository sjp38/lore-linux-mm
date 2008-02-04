Message-Id: <20080204170409.991123259@szeredi.hu>
Date: Mon, 04 Feb 2008 18:04:10 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/3] add perform_write to a_ops
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

a_ops->perform_write() was left out from Nick Piggin's new a_ops
patchset, as it was non-essential, and postponed for later inclusion.

This short series reintroduces it, but only adds the fuse
implementation and not simple_perform_write(), which I'm not sure
would be a significant improvement.

This allows larger than 4k buffered writes for fuse, which is one of
the most requested features.

This goes on top of the "fuse: writable mmap" patches.

Thanks,
Miklos

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

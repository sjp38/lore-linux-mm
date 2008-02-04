Message-Id: <20080204144142.002127391@szeredi.hu>
Date: Mon, 04 Feb 2008 15:41:42 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 0/3] fuse: writable mmap
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is short series for fuse writable mmap support.

The first two patches are small additions to mm infrastructure.  The
third is a large patch for fuse.  It also depends on the "mm: bdi:
export BDI attributes in sysfs" series.

I don't mind if this goes into 2.6.25 (guess, that depends on whether
the bdi things go).

Thanks,
Miklos

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

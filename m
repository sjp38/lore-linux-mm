Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 41C2F6B004F
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:26:16 -0500 (EST)
Message-Id: <20111129130900.628549879@intel.com>
Date: Tue, 29 Nov 2011 21:09:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/9] readahead stats/tracing, backwards prefetching and more (v2)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

Andrew,

This is what the bit fields look like :)

Changes since v1:
- use bit fields: pattern, for_mmap, for_metadata, lseek
- comment the various readahead patterns
- drop boot options "readahead=" and "readahead_stats="
- add for_metadata
- add snapping to EOF

 [PATCH 1/9] block: limit default readahead size for small devices
 [PATCH 2/9] readahead: snap readahead request to EOF
 [PATCH 3/9] readahead: record readahead patterns
 [PATCH 4/9] readahead: tag mmap page fault call sites
 [PATCH 5/9] readahead: tag metadata call sites
 [PATCH 6/9] readahead: add /debug/readahead/stats
 [PATCH 7/9] readahead: add vfs/readahead tracing event
 [PATCH 8/9] readahead: basic support for backwards prefetching
 [PATCH 9/9] readahead: dont do start-of-file readahead after lseek()

 block/genhd.c              |   20 ++
 fs/ext3/dir.c              |    1 
 fs/ext4/dir.c              |    1 
 fs/read_write.c            |    3 
 include/linux/fs.h         |   41 +++++
 include/linux/mm.h         |    4 
 include/trace/events/vfs.h |   64 ++++++++
 mm/Kconfig                 |   15 ++
 mm/filemap.c               |    9 -
 mm/readahead.c             |  257 ++++++++++++++++++++++++++++++++++-
 10 files changed, 404 insertions(+), 11 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

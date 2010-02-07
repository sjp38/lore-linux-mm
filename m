From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/11] 512K readahead size with thrashing safe readahead
Date: Sun, 07 Feb 2010 12:10:13 +0800
Message-ID: <20100207041013.891441102@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NdyXI-0000Su-0b
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Feb 2010 05:14:16 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 04F546B0047
	for <linux-mm@kvack.org>; Sat,  6 Feb 2010 23:14:10 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,

It seems there are no strong objections against the 512KB readahead size.
(Or, anyone would prefer an 1MB readahead? Chris Mason picked a 4MB size
 for btrfs after all.)

So would you include the patchset for wider tests in -mm? I reordered the
patchset a bit: the first 2 patches are good candidates for 2.6.34, while
the others may need longer tests.

Changes since RFC:
- move the lenthy intro text to individual patch changelogs
- treat get_capacity()==0 as uninitilized value (Thanks to Vivek Goyal)
- increase readahead size limit for small devices (Thanks to Jens Axboe)
- add fio test results by Vivek Goyal

	[PATCH 01/11] readahead: limit readahead size for small devices
	[PATCH 02/11] readahead: retain inactive lru pages to be accessed soon

	[PATCH 03/11] readahead: bump up the default readahead size
	[PATCH 04/11] readahead: introduce {MAX|MIN}_READAHEAD_PAGES macros for ease of use
	[PATCH 05/11] readahead: replace ra->mmap_miss with ra->ra_flags
	[PATCH 06/11] readahead: thrashing safe context readahead
	[PATCH 07/11] readahead: record readahead patterns
	[PATCH 08/11] readahead: add tracing event
	[PATCH 09/11] readahead: add /debug/readahead/stats
	[PATCH 10/11] readahead: dont do start-of-file readahead after lseek()
	[PATCH 11/11] radixtree: speed up next/prev hole search

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

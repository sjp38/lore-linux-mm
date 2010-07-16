Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B15EF620201
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 08:38:17 -0400 (EDT)
Received: by mail-pv0-f169.google.com with SMTP id 30so927427pvc.14
        for <linux-mm@kvack.org>; Fri, 16 Jul 2010 05:38:16 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 8/8] Document sysfs entries
Date: Fri, 16 Jul 2010 18:07:50 +0530
Message-Id: <1279283870-18549-9-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 Documentation/ABI/testing/sysfs-kernel-mm-zcache |   53 ++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-zcache

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-zcache b/Documentation/ABI/testing/sysfs-kernel-mm-zcache
new file mode 100644
index 0000000..7ee3f31
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-zcache
@@ -0,0 +1,53 @@
+What:		/sys/kernel/mm/zcache
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		/sys/kernel/mm/zcache directory contains compressed cache
+		statistics for each pool. A separate pool is created for
+		every mount instance of cleancache-aware filesystems.
+
+What:		/sys/kernel/mm/zcache/pool<id>/zero_pages
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The zero_pages file is read-only and specifies number of zero
+		filled pages found in this pool.
+
+What:		/sys/kernel/mm/zcache/pool<id>/orig_data_size
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The orig_data_size file is read-only and specifies uncompressed
+		size of data stored in this pool. This excludes zero-filled
+		pages (zero_pages) since no memory is allocated for them.
+		Unit: bytes
+
+What:		/sys/kernel/mm/zcache/pool<id>/compr_data_size
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The compr_data_size file is read-only and specifies compressed
+		size of data stored in this pool. So, compression ratio can be
+		calculated using orig_data_size and this statistic.
+		Unit: bytes
+
+What:		/sys/kernel/mm/zcache/pool<id>/mem_used_total
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The mem_used_total file is read-only and specifies the amount
+		of memory, including allocator fragmentation and metadata
+		overhead, allocated for this pool. So, allocator space
+		efficiency can be calculated using compr_data_size and this
+		statistic.
+		Unit: bytes
+
+What:		/sys/kernel/mm/zcache/pool<id>/memlimit
+Date:		July 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The memlimit file is read-write and specifies upper bound on
+		the compressed data size (compr_data_dize) stored in this pool.
+		The value specified is rounded down to nearest multiple of
+		PAGE_SIZE.
+		Unit: bytes
\ No newline at end of file
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

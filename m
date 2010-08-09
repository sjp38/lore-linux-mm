Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 77299600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 13:27:47 -0400 (EDT)
Received: by mail-fx0-f41.google.com with SMTP id 3so191513fxm.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 10:27:45 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 10/10] Document sysfs entries
Date: Mon,  9 Aug 2010 22:56:56 +0530
Message-Id: <1281374816-904-11-git-send-email-ngupta@vflare.org>
In-Reply-To: <1281374816-904-1-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>
Cc: Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---
 Documentation/ABI/testing/sysfs-block-zram |   99 ++++++++++++++++++++++++++++
 1 files changed, 99 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-block-zram

diff --git a/Documentation/ABI/testing/sysfs-block-zram b/Documentation/ABI/testing/sysfs-block-zram
new file mode 100644
index 0000000..c8b3b48
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-block-zram
@@ -0,0 +1,99 @@
+What:		/sys/block/zram<id>/disksize
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The disksize file is read-write and specifies the disk size
+		which represents the limit on the *uncompressed* worth of data
+		that can be stored in this disk.
+
+What:		/sys/block/zram<id>/initstate
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The disksize file is read-only and shows the initialization
+		state of the device.
+
+What:		/sys/block/zram<id>/reset
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The disksize file is write-only and allows resetting the
+		device. The reset operation frees all the memory assocaited
+		with this device.
+
+What:		/sys/block/zram<id>/num_reads
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The num_reads file is read-only and specifies the number of
+		reads (failed or successful) done on this device.
+
+What:		/sys/block/zram<id>/num_writes
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The num_writes file is read-only and specifies the number of
+		writes (failed or successful) done on this device.
+
+What:		/sys/block/zram<id>/invalid_io
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The invalid_io file is read-only and specifies the number of
+		non-page-size-aligned I/O requests issued to this device.
+
+What:		/sys/block/zram<id>/notify_free
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The notify_free file is read-only and specifies the number of
+		swap slot free notifications received by this device. These
+		notifications are send to a swap block device when a swap slot
+		is freed. This statistic is applicable only when this disk is
+		being used as a swap disk.
+
+What:		/sys/block/zram<id>/discard
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The discard file is read-only and specifies the number of
+		discard requests received by this device. These requests
+		provide information to block device regarding blocks which are
+		no longer used by filesystem.
+
+What:		/sys/block/zram<id>/zero_pages
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The zero_pages file is read-only and specifies number of zero
+		filled pages written to this disk. No memory is allocated for
+		such pages.
+
+What:		/sys/block/zram<id>/orig_data_size
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The orig_data_size file is read-only and specifies uncompressed
+		size of data stored in this disk. This excludes zero-filled
+		pages (zero_pages) since no memory is allocated for them.
+		Unit: bytes
+
+What:		/sys/block/zram<id>/compr_data_size
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The compr_data_size file is read-only and specifies compressed
+		size of data stored in this disk. So, compression ratio can be
+		calculated using orig_data_size and this statistic.
+		Unit: bytes
+
+What:		/sys/block/zram<id>/mem_used_total
+Date:		August 2010
+Contact:	Nitin Gupta <ngupta@vflare.org>
+Description:
+		The mem_used_total file is read-only and specifies the amount
+		of memory, including allocator fragmentation and metadata
+		overhead, allocated for this disk. So, allocator space
+		efficiency can be calculated using compr_data_size and this
+		statistic.
+		Unit: bytes
\ No newline at end of file
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

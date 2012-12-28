Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id D0D7E8D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:32:29 -0500 (EST)
From: Petr Holasek <pholasek@redhat.com>
Subject: [PATCH v7 2/2] Documentation: add sysfs ABI documentation for ksm
Date: Fri, 28 Dec 2012 02:32:17 +0100
Message-Id: <1356658337-12540-2-git-send-email-pholasek@redhat.com>
In-Reply-To: <1356658337-12540-1-git-send-email-pholasek@redhat.com>
References: <20121224050817.GA25749@kroah.com>
 <1356658337-12540-1-git-send-email-pholasek@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>, Petr Holasek <pholasek@redhat.com>

This patch adds sysfs documentation for Kernel Samepage Merging (KSM)
including new merge_across_nodes knob.

Signed-off-by: Petr Holasek <pholasek@redhat.com>
---
 Documentation/ABI/testing/sysfs-kernel-mm-ksm | 51 +++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-ksm

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-ksm b/Documentation/ABI/testing/sysfs-kernel-mm-ksm
new file mode 100644
index 0000000..44384ae
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-ksm
@@ -0,0 +1,51 @@
+What:		/sys/kernel/mm/ksm
+Date:		September 2009
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	/sys/kernel/mm/ksm contains interface of Kernel Samepage
+		Merging (KSM)
+
+What:		/sys/kernel/mm/ksm/full_scans
+What:		/sys/kernel/mm/ksm/pages_shared
+What:		/sys/kernel/mm/ksm/pages_sharing
+What:		/sys/kernel/mm/ksm/pages_to_scan
+What:		/sys/kernel/mm/ksm/pages_unshared
+What:		/sys/kernel/mm/ksm/pages_volatile
+What:		/sys/kernel/mm/ksm/run
+What:		/sys/kernel/mm/ksm/sleep_millisecs
+Date:		September 2009
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	Kernel Samepage Merging daemon sysfs interface
+
+		full_scans: how many times all mergeable areas have been
+		scanned.
+
+		pages_shared: how many shared pages are being used.
+
+		pages_sharing: how many more sites are sharing them i.e. how
+		much saved.
+
+		pages_to_scan: how many present pages to scan before ksmd goes
+		to sleep.
+
+		pages_unshared: how many pages unique but repeatedly checked
+		for merging.
+
+		pages_volatile: how many pages changing too fast to be placed
+		in a tree.
+
+		run: write 0 to disable ksm, read 0 while ksm is disabled.
+			write 1 to run ksm, read 1 while ksm is running.
+			write 2 to disable ksm and unmerge all its pages.
+
+		sleep_millisecs: how many milliseconds ksm should sleep between
+		scans.
+
+		See Documentation/vm/ksm.txt for more information.
+
+What:		/sys/kernel/mm/ksm/merge_across_nodes
+Date:		December 2012
+Contact:	Linux memory management mailing list <linux-mm@kvack.org>
+Description:	Control merging pages across different NUMA nodes.
+
+		When it is set to 0 only pages from the same node are merged,
+		otherwise pages from all nodes can be merged together (default).
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

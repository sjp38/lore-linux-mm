Date: Mon, 14 Jul 2008 20:01:47 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm] adapt vmscan-unevictable-lru-scan-sysctl.patch  to new sysfs API
Message-Id: <20080714195638.F6DE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Greg Kroah-Hartman <gregkh@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: vmscan-unevictable-lru-scan-sysctl-add-sys_device-parameter.patch
Against: mmotm Jul 14
Applies after: vmscan-unevictable-lru-scan-sysctl-nommu-fix.patch


The second attribute parameter is missing in
read_scan_unevictable_node()/write_scan_unevictable_node().
which has been added recently.

	mm/vmscan.c:2654: warning: initialization from incompatible pointer type
	mm/vmscan.c:2654: warning: initialization from incompatible pointer type

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
CC: Andi Kleen <ak@linux.intel.com>
CC: Greg Kroah-Hartman <gregkh@suse.de>
CC: Lee Schermerhorn <lee.schermerhorn@hp.com>
CC: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2626,12 +2626,15 @@ int scan_unevictable_handler(struct ctl_
  * a specified node's per zone unevictable lists for evictable pages.
  */
 
-static ssize_t read_scan_unevictable_node(struct sys_device *dev, char *buf)
+static ssize_t read_scan_unevictable_node(struct sys_device *dev,
+					  struct sysdev_attribute *attr,
+					  char *buf)
 {
 	return sprintf(buf, "0\n");	/* always zero; should fit... */
 }
 
 static ssize_t write_scan_unevictable_node(struct sys_device *dev,
+					   struct sysdev_attribute *attr,
 					const char *buf, size_t count)
 {
 	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

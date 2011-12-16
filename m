Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D98116B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 08:23:52 -0500 (EST)
Date: Fri, 16 Dec 2011 14:23:50 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -mm] slub: debug_guardpage_minorder documentation tweak
Message-ID: <20111216132349.GB14271@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
 <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com>
 <20111212145948.GA2380@redhat.com>
 <201112130021.41429.rjw@sisk.pl>
 <alpine.DEB.2.00.1112131640240.32369@chino.kir.corp.google.com>
 <20111216132155.GA14271@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111216132155.GA14271@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 Documentation/ABI/testing/sysfs-kernel-slab |    6 ++++--
 Documentation/vm/slub.txt                   |    7 ++++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index bfd1d9f..91bd6ca 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -346,8 +346,10 @@ Description:
 		number of objects per slab.  If a slab cannot be allocated
 		because of fragmentation, SLUB will retry with the minimum order
 		possible depending on its characteristics.
-		When debug_guardpage_minorder > 0 parameter is specified, the
-		minimum possible order is used and cannot be changed.
+		When debug_guardpage_minorder=N (N > 0) parameter is specified
+		(see Documentation/kernel-parameters.txt), the minimum possible
+		order is used and this sysfs entry can not be used to change
+		the order at run time.
 
 What:		/sys/kernel/slab/cache/order_fallback
 Date:		April 2008
diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index dbf02ad..1514d9f 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -131,9 +131,10 @@ slub_min_objects.
 slub_max_order specified the order at which slub_min_objects should no
 longer be checked. This is useful to avoid SLUB trying to generate
 super large order pages to fit slub_min_objects of a slab cache with
-large object sizes into one high order page. Setting parameter
-debug_guardpage_minorder > 0 forces setting slub_max_order to 0, what
-cause minimum possible order of slabs allocation.
+large object sizes into one high order page. Setting command line
+parameter debug_guardpage_minorder=N (N > 0), forces setting
+slub_max_order to 0, what cause minimum possible order of slabs
+allocation.
 
 SLUB Debug output
 -----------------
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

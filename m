Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 8A8746B0189
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:59:53 -0500 (EST)
Date: Mon, 12 Dec 2011 15:59:49 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -mm] slub: document setting min order with
 debug_guardpage_minorder > 0
Message-ID: <20111212145948.GA2380@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
 <1321633507-13614-3-git-send-email-sgruszka@redhat.com>
 <alpine.DEB.2.00.1112071407090.27360@chino.kir.corp.google.com>
 <20111208073316.GA2402@redhat.com>
 <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
English is hard (definitely harder than C language :-), so please correct
me, if I wrote something wrong.

 Documentation/ABI/testing/sysfs-kernel-slab |    4 +++-
 Documentation/vm/slub.txt                   |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 8b093f8..d84ca80 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -345,7 +345,9 @@ Description:
 		allocated.  It is writable and can be changed to increase the
 		number of objects per slab.  If a slab cannot be allocated
 		because of fragmentation, SLUB will retry with the minimum order
-		possible depending on its characteristics.
+		possible depending on its characteristics. 
+		When debug_guardpage_minorder > 0 parameter is specified, the
+		minimum possible order is used and cannot be changed.
 
 What:		/sys/kernel/slab/cache/order_fallback
 Date:		April 2008
diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index f464f47..dbf02ad 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -131,7 +131,9 @@ slub_min_objects.
 slub_max_order specified the order at which slub_min_objects should no
 longer be checked. This is useful to avoid SLUB trying to generate
 super large order pages to fit slub_min_objects of a slab cache with
-large object sizes into one high order page.
+large object sizes into one high order page. Setting parameter
+debug_guardpage_minorder > 0 forces setting slub_max_order to 0, what
+cause minimum possible order of slabs allocation.
 
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

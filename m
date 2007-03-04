From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH 3/3] mm: Remove nosave and nosave_free page flags
Date: Sun, 4 Mar 2007 15:08:11 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703011633.54625.rjw@sisk.pl> <200703041450.02178.rjw@sisk.pl>
In-Reply-To: <200703041450.02178.rjw@sisk.pl>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200703041508.12540.rjw@sisk.pl>
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Pavel Machek <pavel@ucw.cz>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Johannes Berg <johannes@sipsolutions.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Remove two page flags that are no longer needed.

---
 include/linux/page-flags.h |   12 ------------
 1 file changed, 12 deletions(-)

Index: linux-2.6.21-rc2/include/linux/page-flags.h
===================================================================
--- linux-2.6.21-rc2.orig/include/linux/page-flags.h	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.21-rc2/include/linux/page-flags.h	2007-03-04 13:37:57.000000000 +0100
@@ -82,13 +82,11 @@
 #define PG_private		11	/* If pagecache, has fs-private data */
 
 #define PG_writeback		12	/* Page is under writeback */
-#define PG_nosave		13	/* Used for system suspend/resume */
 #define PG_compound		14	/* Part of a compound page */
 #define PG_swapcache		15	/* Swap page: swp_entry_t in private */
 
 #define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
 #define PG_reclaim		17	/* To be reclaimed asap */
-#define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
 
@@ -212,16 +210,6 @@ static inline void SetPageUptodate(struc
 		ret;							\
 	})
 
-#define PageNosave(page)	test_bit(PG_nosave, &(page)->flags)
-#define SetPageNosave(page)	set_bit(PG_nosave, &(page)->flags)
-#define TestSetPageNosave(page)	test_and_set_bit(PG_nosave, &(page)->flags)
-#define ClearPageNosave(page)		clear_bit(PG_nosave, &(page)->flags)
-#define TestClearPageNosave(page)	test_and_clear_bit(PG_nosave, &(page)->flags)
-
-#define PageNosaveFree(page)	test_bit(PG_nosave_free, &(page)->flags)
-#define SetPageNosaveFree(page)	set_bit(PG_nosave_free, &(page)->flags)
-#define ClearPageNosaveFree(page)		clear_bit(PG_nosave_free, &(page)->flags)
-
 #define PageBuddy(page)		test_bit(PG_buddy, &(page)->flags)
 #define __SetPageBuddy(page)	__set_bit(PG_buddy, &(page)->flags)
 #define __ClearPageBuddy(page)	__clear_bit(PG_buddy, &(page)->flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 2 Oct 2006 10:10:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060930130811.2a7c0009.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610021008510.12554@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060924030643.e57f700c.akpm@osdl.org> <20060927021934.9461b867.akpm@osdl.org>
 <451A6034.20305@shadowen.org> <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
 <20060930130811.2a7c0009.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Sep 2006, Andrew Morton wrote:

> BUILD_BUG_ON()?

Good idea. We may want to take all of these patches out if Andy can come 
up with an easy modification to the macros that avoids ZONEID_PGSHIFT to 
unintentionally become 0.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.18-mm2.orig/include/linux/mm.h	2006-09-30 13:33:27.000000000 -0500
+++ linux-2.6.18-mm2/include/linux/mm.h	2006-10-02 12:08:14.387946148 -0500
@@ -452,7 +452,7 @@ static inline enum zone_type page_zonenu
  */
 static inline int page_zone_id(struct page *page)
 {
-	BUG_ON(ZONEID_PGSHIFT == 0 && ZONEID_MASK);
+	BUILD_BUG_ON(ZONEID_PGSHIFT == 0 && ZONEID_MASK);
 	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 23 Oct 2006 18:07:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0610231806280.1254@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fix return of a value in function returning void.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc2-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.19-rc2-mm2.orig/mm/page_alloc.c	2006-10-23 17:57:53.000000000 -0500
+++ linux-2.6.19-rc2-mm2/mm/page_alloc.c	2006-10-23 20:05:44.146460919 -0500
@@ -3071,7 +3071,7 @@ static void setup_per_zone_lowmem_reserv
 	enum zone_type j, idx;
 
 	if (!CONFIG_MULTI_ZONE)
-		return 0;
+		return;
 
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

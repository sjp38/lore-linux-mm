Date: Wed, 14 Nov 2007 13:13:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0711141312510.19433@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, apw@shadowen.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Remove unused leftover variable.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/page_alloc.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6.24-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/page_alloc.c	2007-11-14 13:12:02.256478626 -0800
+++ linux-2.6.24-rc2-mm1/mm/page_alloc.c	2007-11-14 13:12:16.557288771 -0800
@@ -910,7 +910,6 @@ static void drain_pages(unsigned int cpu
 {
 	unsigned long flags;
 	struct zone *zone;
-	int i;
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

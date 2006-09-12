Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C1d4nx008908
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 20:39:04 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8C1c7Du52900112
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:38:08 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8C1d3nB56345863
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:39:03 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GMxEs-0001zR-00
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:39:02 -0700
Date: Mon, 11 Sep 2006 17:19:20 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: [PATCH] zone_to_nid: One additional case
Message-ID: <Pine.LNX.4.64.0609111717480.7490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0609111838560.7652@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I found another situation where one can use zone_to_nid to clarify
the source.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/mm/oom_kill.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/oom_kill.c	2006-09-08 06:43:05.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/oom_kill.c	2006-09-11 17:37:40.079357973 -0500
@@ -177,8 +177,7 @@
 
 	for (z = zonelist->zones; *z; z++)
 		if (cpuset_zone_allowed(*z, gfp_mask))
-			node_clear((*z)->zone_pgdat->node_id,
-					nodes);
+			node_clear(zone_to_nid(*z), nodes);
 		else
 			return CONSTRAINT_CPUSET;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

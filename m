Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8IMlKt8029226
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 15:47:21 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8IKBc8s41296133
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 13:11:38 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8IKBcnB57329946
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 13:11:38 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GPPSs-0007Sk-00
	for <linux-mm@kvack.org>; Mon, 18 Sep 2006 13:11:38 -0700
Date: Mon, 18 Sep 2006 13:11:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Do not allocate pagesets for unpopulated zones. (fwd)
Message-ID: <Pine.LNX.4.64.0609181311010.28689@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

My dyslexia hit linux-mm@vger.kernel.org again. sigh.

---------- Forwarded message ----------
Date: Mon, 18 Sep 2006 13:07:09 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Cc: linux-mm@vger.kernel.org
To: akpm@osdl.org
Subject: [PATCH] Do not allocate pagesets for unpopulated zones.

We do not need to allocate pagesets for unpopulated zones.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-18 14:14:58.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-18 14:54:43.456849813 -0500
@@ -1903,6 +1903,9 @@ static int __cpuinit process_zones(int c
 
 	for_each_zone(zone) {
 
+		if (!populated_zone(zone))
+			continue;
+
 		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
 					 GFP_KERNEL, cpu_to_node(cpu));
 		if (!zone_pcp(zone, cpu))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

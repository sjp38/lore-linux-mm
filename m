Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DAB566B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 17:51:35 -0400 (EDT)
Date: Mon, 13 Jul 2009 23:17:48 +0100 (BST)
From: Alexey Korolev <akorolev@infradead.org>
Subject: [RFC][PATCH 0/2] HugeTLB mapping for drivers
Message-ID: <alpine.LFD.2.00.0907132312550.25576@casper.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch listed below provides device drivers with possibility to map
memory regions to user mode via HTLB interfaces.

This post is continuation of the topic being discussed here
http://marc.info/?l=linux-mm&m=124478168514639&w=2 . 
Thanks to Mel who gave good advice and code prototype. Couple weeks were
spent to understand how hugetlb works and initial version of the patch
is done. 

Why we need it? It is a common practice for device drivers to map memory
regions to user-space to allow data handling in user mode. (There are
plenty of examples in driver folder). Involving hugetlb mapping may
bring performance gain if mapped region is relatively large. Our tests
showed that it is possible to gain up to 7% performance gain if htlb
mapping is enabled. In my case involving hugetlb starts to make sense if
buffer is more or equal to 4MB. Since devices throughput grow up there
are more and more reasons to involve huge pages to remap very large mem regions.

The following messages contain patch and a simple driver example.
Patch has early revision. There are many doubtful places. Your critics
and suggestions are welocme.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

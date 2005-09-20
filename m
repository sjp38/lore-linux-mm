Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8KHM27h023058
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 13:22:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8KHNfs9536434
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8KHNArG029708
	for <linux-mm@kvack.org>; Tue, 20 Sep 2005 11:23:10 -0600
Subject: [RFC][PATCH 0/4] unify both copies of build_zonelists()
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 20 Sep 2005 10:23:03 -0700
Message-Id: <20050920172303.8CD9190C@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There are currently two copies of build_zonelists(): one
for NUMA systems, and one for flat systems.  The following
patches make the NUMA case work for the flat case as well.

This set is a little more thorough than the single patch
I posted last week.

I'd like these to get a run in -mm if there aren't any
objections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j14L5w3n021284
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:05:58 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j14L5wWr220288
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:05:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j14L5wQB005578
	for <linux-mm@kvack.org>; Fri, 4 Feb 2005 16:05:58 -0500
Subject: [PATCH 0/3] refactor i386 memory setup
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Fri, 04 Feb 2005 13:05:55 -0800
Message-Id: <1107551155.9084.27.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

The following 3 patches help to make some of the i386 NUMA code a bit
more manageable, and remove a lot of duplicate code in the process.  All
3 together were test-booted on a NUMA-Q, Summit, and a regular old
laptop.

They're in no hurry to get merged, and could wait for the 2.6.12 series.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PM0tuv031601
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:00:55 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PM1KGI178326
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:20 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PM1Kjb028880
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 15:01:20 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/3] hugetlb: Dynamic pool resize improvements
Date: Mon, 25 Feb 2008 14:01:19 -0800
Message-Id: <20080225220119.23627.33676.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>


This series of patches contains fixes for a few issues found with the new
dynamically resizing hugetlb pool while stress testing.  The first patch
corrects the page count for surplus huge pages when they are first allocated.
This avoids a BUG when CONFIG_DEBUG_VM is enabled.  The second patch closes a
difficult to trigger race when setting up a reservation involving surplus pages
which could lead to reservations not being honored.  The third patch is a minor
performance optimization in gather_surplus_huge_pages().  Patches 1 and 2 are
candidates for -stable.

These patches were generated against 2.6.24

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

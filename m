Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m23I5oca021126
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 13:05:50 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23I6Ooi148732
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:28 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23I6NhR008105
	for <linux-mm@kvack.org>; Mon, 3 Mar 2008 11:06:23 -0700
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/3] hugetlb: Dynamic pool resize improvements
Date: Mon, 03 Mar 2008 10:06:22 -0800
Message-Id: <20080303180622.5383.20868.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@csn.ul.ie>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>


Andrew, I think these have now been properly vetted.  Would you consider them
for -mm please?  The first two are bug fixes and should also be considered for
merging into 2.6.25.  The third patch can happily wait until the next merge
window.

This series of patches contains fixes for a few issues found with the new
dynamically resizing hugetlb pool while stress testing.  The first patch
corrects the page count for surplus huge pages when they are first allocated.
This avoids a BUG when CONFIG_DEBUG_VM is enabled.  The second patch closes a
difficult to trigger race when setting up a reservation involving surplus pages
which could lead to reservations not being honored.  The third patch is a minor
performance optimization in gather_surplus_huge_pages().

These patches were generated against 2.6.24

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

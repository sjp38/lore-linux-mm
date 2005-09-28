Subject: earlier allocation of order 0 pages in __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
Content-Type: text/plain
Date: Wed, 28 Sep 2005 14:18:36 -0700
Message-Id: <1127942316.5046.37.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm wondering if it is a good idea in __alloc_pages to first try to see
if a order 0 request can be serviced by cpu's pcp before checking the
low water marks for the zone.  The is useful if a request can be
serviced by a free page on the pcp then there is no reason to check the
zone's limits.  This early allocation should be without any replenishing
of pcps from zone free list

thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

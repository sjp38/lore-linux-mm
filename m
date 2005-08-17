Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j7HJ1NpR225474
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:01:25 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJ10KM507734
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 13:01:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJ1MmJ016410
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 13:01:22 -0600
Subject: [PATCH 0/4] Demand faunting for huge pages
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 13:56:06 -0500
Message-Id: <1124304966.3139.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: agl@us.ibm.com, christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

The following patch set implements demand faulting for huge pages.  In
response to helpful feedback from Christoph Lameter, Kenneth Chen, and
Andi Kleen, I've split up the demand fault patch (previously posted on
LKML: http://lkml.org/lkml/2005/8/5/154 ) into a smaller, more
digestible set.

The first three patches should be pretty clear-cut and harmless and just
make way for a neater switch to demand faulting.  The code touched by
the x86 patches is either already present or (AFAICT) not needed for
other architectures.  Comments?  Anyone want to try this out on their
specific huge page workload and architecture combinati?

The patches are:
  x86-pte_huge - Create pte_huge() test function
  x86-move-stale-pgtable - Check for stale pte in huge_pte_alloc()
  x86-walk-check - Check for not present huge page table entries
  htlb-fault - Demand faulting for huge pages

Patches coming soon in reply to this message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

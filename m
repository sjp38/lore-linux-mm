Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA05697
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:12:37 -0800 (PST)
Date: Fri, 31 Jan 2003 15:15:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: hugepage patches
Message-Id: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>, "Seth, Rohit" <rohit.seth@intel.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>, William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Gentlemen, I have a bunch of patches here which fix various bugs in the
interaction between hugepages and other kernel functions.

The main impact on hugetlbpage impementations is:

- hugepages are no longer PG_reserved

- hugepages must be page_cache_got in the follow_page() function

- need to implement either hugepage_vma()/follow_huge_addr() or
  pmd_huge()/follow_huge_pmd(), depending on whether a page's hugeness can be
  determined via pmd inspection.  Implementations of both schemes for ia32
  are here.

The code is not heavily tested or reviewed at this time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

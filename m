Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5CIn23U030939
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:49:02 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5CIn2iM076832
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:49:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5CIn1SX017962
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:49:01 -0400
Subject: [RFC PATCH 0/2] Merge HUGETLB_PAGE and HUGETLBFS Kconfig options
From: Adam Litke <agl@us.ibm.com>
Content-Type: text/plain
Date: Thu, 12 Jun 2008 14:49:00 -0400
Message-Id: <1213296540.17108.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: agl@us.ibm.com, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

There are currently two global Kconfig options that enable/disable the
hugetlb code: CONFIG_HUGETLB_PAGE and CONFIG_HUGETLBFS.  This may have
made sense before hugetlbfs became ubiquitous but now the pair of
options are redundant.  Merging these two options into one will simplify
the code slightly and will, more importantly, avoid confusion and
questions like: Which hugetlbfs CONFIG option should my code depend on?

CONFIG_HUGETLB_PAGE is aliased to the value of CONFIG_HUGETLBFS, so one
option can be removed without any effect.  The first patch merges the
two options into one option: CONFIG_HUGETLB.  The second patch updates
the defconfigs to set the one new option appropriately.

I have cross-compiled this on i386, x86_64, ia64, powerpc, sparc64 and
sh with the option enabled and disabled.  This is completely mechanical
but, due to the large number of files affected (especially defconfigs),
could do well with a review from several sets of eyeballs.  Thanks.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

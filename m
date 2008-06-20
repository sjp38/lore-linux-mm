From: Andy Whitcroft <apw@shadowen.org>
Subject: [RFC] hugetlb reservations -- MAP_PRIVATE fixes for split vmas
Date: Fri, 20 Jun 2008 20:17:52 +0100
Message-Id: <1213989474-5586-1-git-send-email-apw@shadowen.org>
In-Reply-To: <485A8903.9030808@linux.vnet.ibm.com>
References: <485A8903.9030808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

As reported by Adam Litke and Jon Tollefson one of the libhugetlbfs
regression tests triggers a negative overall reservation count.  When
this occurs where there is no dynamic pool enabled tests will fail.

Following this email are two patches to fix this issue:

hugetlb reservations: move region tracking earlier -- simply moves the
  region tracking code earlier so we do not have to supply prototypes, and

hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma
  splits -- which moves us to tracking the consumed reservation so that
  we can correctly calculate the remaining reservations at vma close time.

This stack is against the top of v2.6.25-rc6-mm3, should this solution
prove acceptable it would probabally need porting below Nicks multiple
hugepage size patches and those updated; if so I would be happy to do
that too.

Jon could you have a test on this and see if it works out for you.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

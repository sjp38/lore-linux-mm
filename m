Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A02D36B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 11:45:57 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 30 Jun 2009 11:47:16 -0400
Message-Id: <20090630154716.1583.25274.sendpatchset@lts-notebook>
Subject: [RFC 0/3] hugetlb: constrain allocation/free based on task mempolicy
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

RFC 0/3 hugetlb: constrain allocation/free based on task mempolicy

Against:  25jun09 mmotm atop the "hugetlb:  balance freeing..."
series

This is V1 of a series of patches to constrain the allocation and
freeing of persistent huge pages using the task NUMA mempolicy of
the task modifying "nr_hugepages".  This series is based on Mel
Gorman's suggestion to use task mempolicy.

I have some concerns about a subtle change in behavior [see patch
2/3 and the updated documentation] and the fact that
this mechanism ignores some of the semantics of the mempolicy
mode [again, see the doc].   However, this method seems to work
fairly well.  And, IMO, the resulting code doesn't look all that
bad.

A couple of limitations in this version:

1) I haven't implemented a boot time parameter to constrain the
   boot time allocation of huge pages.  This can be added if
   anyone feels strongly that it is required.

2) I have not implemented a per node nr_overcommit_hugepages as
   David Rientjes and I discussed earlier.  Again, this can be
   added and specific nodes can be addressed using the mempolicy
   as this series does for allocation and free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

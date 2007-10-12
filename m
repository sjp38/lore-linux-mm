From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 12 Oct 2007 11:48:54 -0400
Message-Id: <20071012154854.8157.51441.sendpatchset@localhost>
Subject: [PATCH/RFC 0/4] More Mempolicy Reference Counting Fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, clameter@sgi.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH 0/4 Memory Policy: More Reference Counting and Fallback Fixes

While testing huge pages using shm segments created with the SHM_HUGETLB flag,
came across additional problems with memory policy reference counting.  Some
of the problems were introduced by myself in my previous mempolicy ref counting
patch, and some were just paths that I missed in my inspection and testing. 

This resend separates the 2nd patch of the previous posting into 3 separate
fixes for 3 separate, but interrelated, issues.  At Christoph Lameter's 
request.  Rebuilt and cursory testing on x86_64 numa platform only.

These 4 patches are based against 2.6.23-rc8-mm2, but should also probably
go to the .23-stable tree when it opens.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

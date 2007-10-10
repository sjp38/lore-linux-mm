From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 10 Oct 2007 16:58:37 -0400
Message-Id: <20071010205837.7230.42818.sendpatchset@localhost>
Subject: [PATCH/RFC 0/2] More Mempolicy Reference Counting Fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: ak@suse.de, clameter@sgi.com, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH 0/2 Memory Policy: More Reference Counting Fixes

While testing huge pages using shm segments created with the SHM_HUGETLB flag,
I came across additional problems with memory policy reference counting.  While
tracking these down, I found even more...  Some of the problems were introduced
by myself in my previous mempolicy ref counting patch, and some were paths that
I missed in my inspection and testing. 

These 2 patches are both based against 2.6.23-rc8-mm2, but should also probably
go to the .23-stable tree when it opens.  They have been tested on ia64 and
x86_64 platforms.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

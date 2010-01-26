Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 32CC36B0096
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:59:29 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 31] define MADV_HUGEPAGE
Message-Id: <da09747e3b1d0368a0a6.1264513916@v2.random>
In-Reply-To: <patchbomb.1264513915@v2.random>
References: <patchbomb.1264513915@v2.random>
Date: Tue, 26 Jan 2010 14:51:56 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Define MADV_HUGEPAGE.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mman-common.h
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -45,6 +45,8 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	15		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

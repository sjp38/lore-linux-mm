Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7456F6B009B
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:54:12 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/4] slqb: Allow SLQB to be used on PPC and S390
Date: Tue, 22 Sep 2009 13:54:14 +0100
Message-Id: <1253624054-10882-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

SLQB was disabled on PPC as it would stab itself in the face when running
on machines with CPUs on memoryless nodes and was disabled on S390 due
to other functionality difficulties. S390 has been independently fixed
and PPC should work in most configurations with remote locking of nodes
still with some difficulties. Allow SLQB to be configured again so the
dodgy configurations can be further identified and debugged.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 init/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index adc10ab..c56248f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1033,7 +1033,6 @@ config SLUB
 
 config SLQB
 	bool "SLQB (Queued allocator)"
-	depends on !PPC && !S390
 	help
 	  SLQB is a proposed new slab allocator.
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

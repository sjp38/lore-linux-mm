Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF92E6B00A3
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 12:10:29 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] slqb: Allow SLQB to be used on PPC
Date: Mon, 21 Sep 2009 17:10:26 +0100
Message-Id: <1253549426-917-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

SLQB was disabled on PPC as it would stab itself in the face when running
on machines with CPUs on memoryless nodes. As those configurations should
now work, allow SLQB to be configured again on PPC.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 init/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index adc10ab..8f55fde 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1033,7 +1033,7 @@ config SLUB
 
 config SLQB
 	bool "SLQB (Queued allocator)"
-	depends on !PPC && !S390
+	depends on !S390
 	help
 	  SLQB is a proposed new slab allocator.
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

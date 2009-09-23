Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFB56B00BE
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:53 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 55/80] c/r: (s390): expose a constant for the number of words (CRs)
Date: Wed, 23 Sep 2009 19:51:35 -0400
Message-Id: <1253749920-18673-56-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Dan Smith <danms@us.ibm.com>
List-ID: <linux-mm.kvack.org>

We need to use this value in the checkpoint/restart code and would like to
have a constant instead of a magic '3'.

Changelog:
    Mar 30:
            . Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
    Mar 03:
            . Picked up additional use of magic '3' in ptrace.h

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 arch/s390/Kconfig |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 2ae5d72..6f143ab 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -49,6 +49,10 @@ config GENERIC_TIME_VSYSCALL
 config GENERIC_CLOCKEVENTS
 	def_bool y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y if 64BIT
+
 config GENERIC_BUG
 	bool
 	depends on BUG
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

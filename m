Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE1F6B00B9
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:49 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 75/80] powerpc: reserve checkpoint arch identifiers
Date: Wed, 23 Sep 2009 19:51:55 -0400
Message-Id: <1253749920-18673-76-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Nathan Lynch <ntl@pobox.com>
List-ID: <linux-mm.kvack.org>

From: Nathan Lynch <ntl@pobox.com>

Signed-off-by: Nathan Lynch <ntl@pobox.com>
---
 include/linux/checkpoint_hdr.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 9ae35a0..2ed523f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -117,6 +117,8 @@ enum {
 	/* do not change order (will break ABI) */
 	CKPT_ARCH_X86_32 = 1,
 	CKPT_ARCH_S390X,
+	CKPT_ARCH_PPC32,
+	CKPT_ARCH_PPC64,
 };
 
 /* shared objrects (objref) */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

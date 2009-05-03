Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 385756B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 21:09:46 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2329703wfa.11
        for <linux-mm@kvack.org>; Sat, 02 May 2009 18:09:54 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 3 May 2009 10:09:54 +0900
Message-ID: <3ecd1e960905021809p448f6b0eo3a530cd35d4f763e@mail.gmail.com>
Subject: [PATCH] gfp.h: a trivial comment typo
From: Kazuo Ito <kzpn200@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

It's really trivial and doesn't mean much for overall code
quality, but since I found it...

commit 99b4ac1ebc20382c2215ae984d565ab183e0f4bc
Author: Kazuo Ito <kzpn200@gmail.com>
Date:   Sun May 3 09:56:35 2009 +0900

    gfp.h: a comment typo
---
 include/linux/gfp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0bbc15f..eda48ed 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -14,7 +14,7 @@ struct vm_area_struct;
  * Zone modifiers (see linux/mmzone.h - low three bits)
  *
  * Do not put any conditional on these. If necessary modify the definitions
- * without the underscores and use the consistently. The definitions here may
+ * without the underscores and use them consistently. The definitions here may
  * be used in bit comparisons.
  */
 #define __GFP_DMA	((__force gfp_t)0x01u)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

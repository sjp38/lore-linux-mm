Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 617BF6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 01:23:16 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id 9so25151449iom.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 22:23:16 -0800 (PST)
Received: from mgwym02.jp.fujitsu.com (mgwym02.jp.fujitsu.com. [211.128.242.41])
        by mx.google.com with ESMTPS id u91si2676961ioi.105.2016.02.16.22.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 22:23:15 -0800 (PST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 35167AC01AE
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 15:23:10 +0900 (JST)
From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Subject: [PATCH] mm: remove unnecessary description about a non-exist gfp flag
Message-ID: <56C411A3.6090208@jp.fujitsu.com>
Date: Wed, 17 Feb 2016 15:22:27 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Since __GFP_NOACCOUNT is removed by the following commit,
its description is not necessary.

commit 20b5c3039863 ("Revert 'gfp: add __GFP_NOACCOUNT'")

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
---
 include/linux/gfp.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index af1f2b2..7c76a6e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -101,8 +101,6 @@ struct vm_area_struct;
  *
  * __GFP_NOMEMALLOC is used to explicitly forbid access to emergency reserves.
  *   This takes precedence over the __GFP_MEMALLOC flag if both are set.
- *
- * __GFP_NOACCOUNT ignores the accounting for kmemcg limit enforcement.
  */
 #define __GFP_ATOMIC	((__force gfp_t)___GFP_ATOMIC)
 #define __GFP_HIGH	((__force gfp_t)___GFP_HIGH)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

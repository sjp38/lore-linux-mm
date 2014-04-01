Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2CF3E6B0037
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 02:43:37 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so8995936pdj.26
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 23:43:36 -0700 (PDT)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id mu18si10549683pab.436.2014.03.31.23.43.30
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 23:43:36 -0700 (PDT)
Message-ID: <533A5FCB.50502@cn.fujitsu.com>
Date: Tue, 01 Apr 2014 14:42:19 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] madvise: Correct the comment of MADV_DODUMP flag
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

s/MADV_NODUMP/MADV_DONTDUMP/

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/uapi/asm-generic/mman-common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529..ddc3b36 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -50,7 +50,7 @@

 #define MADV_DONTDUMP   16             /* Explicity exclude from the core dump,
                                           overrides the coredump filter bits */
-#define MADV_DODUMP    17              /* Clear the MADV_NODUMP flag */
+#define MADV_DODUMP    17              /* Clear the MADV_DONTDUMP flag */

 /* compatibility flags */
 #define MAP_FILE       0
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

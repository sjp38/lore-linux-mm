Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 335EF6B0031
	for <linux-mm@kvack.org>; Sun, 30 Mar 2014 23:06:42 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f51so6748435qge.2
        for <linux-mm@kvack.org>; Sun, 30 Mar 2014 20:06:41 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id a59si5650328qge.139.2014.03.30.20.06.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 30 Mar 2014 20:06:41 -0700 (PDT)
Message-ID: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 30 Mar 2014 20:06:39 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr@hp.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Davidlohr Bueso <davidlohr@hp.com>

The default size is, and always has been, 32Mb. Today, in the
XXI century, it seems that this value is rather small, making
users have to increase it via sysctl, which can cause unnecessary
work and userspace application workarounds[1]. I have arbitrarily
chosen a 4x increase, leaving it at 128Mb, and naturally, the
same goes for shmall. While it may make more sense to set the value
based on the system memory, this limit must be the same across all
systems, and left to users to change if needed.

[1]: http://rhaas.blogspot.com/2012/06/absurd-shared-memory-limits.html

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/uapi/linux/shm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 78b6941..754b605 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -12,7 +12,7 @@
  * be increased by sysctl
  */
 
-#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
+#define SHMMAX 0x8000000		 /* max shared seg size (bytes) */
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
 #ifndef __KERNEL__
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

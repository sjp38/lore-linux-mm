Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 08FA86B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 15:17:37 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id l6so1805055oag.4
        for <linux-mm@kvack.org>; Wed, 07 May 2014 12:17:36 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id b5si11502459obq.32.2014.05.07.12.17.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 07 May 2014 12:17:36 -0700 (PDT)
Message-ID: <1399490251.4567.24.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH v2] ipc,shm: document new limits in the uapi header
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 07 May 2014 12:17:31 -0700
In-Reply-To: <1399486965.4567.9.camel@buesod1.americas.hpqcorp.net>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
	 <1399406800.13799.20.camel@buesod1.americas.hpqcorp.net>
	 <CAKgNAkjOKP7P9veOpnokNkVXSszVZt5asFsNp7rm7AXJdjcLLA@mail.gmail.com>
	 <1399414081.30629.2.camel@buesod1.americas.hpqcorp.net>
	 <5369C43D.1000206@gmail.com>
	 <1399486965.4567.9.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is useful in the future and allows users to
better understand the reasoning behind the changes.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/uapi/linux/shm.h | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index 74e786d..3400b6e 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -8,17 +8,20 @@
 #endif
 
 /*
- * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be modified by sysctl.
+ * SHMMNI, SHMMAX and SHMALL are the default upper limits which can be
+ * modified by sysctl. Both SHMMAX and SHMALL have their default values
+ * to the maximum limit which is as large as it can be without helping
+ * userspace overflow the values. There is really nothing the kernel
+ * can do to avoid this any further. It is therefore not advised to
+ * make them any larger. These limits are suitable for both 32 and
+ * 64-bit systems.
  */
-
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
-#define SHMMAX (ULONG_MAX - (1L<<24))	 /* max shared seg size (bytes) */
-#define SHMALL (ULONG_MAX - (1L<<24))	 /* max shm system wide (pages) */
+#define SHMMAX (ULONG_MAX - (1UL << 24)) /* max shared seg size (bytes) */
+#define SHMALL (ULONG_MAX - (1UL << 24)) /* max shm system wide (pages) */
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 
-
 /* Obsolete, used only for backwards compatibility and libc5 compiles */
 struct shmid_ds {
 	struct ipc_perm		shm_perm;	/* operation perms */
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

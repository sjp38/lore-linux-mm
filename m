Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B58DD6B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 21:01:16 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so1520895pac.8
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 18:01:16 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id gf1si355878pbc.79.2015.01.06.18.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 18:01:15 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so1433613pdb.10
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 18:01:14 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 7 Jan 2015 10:01:14 +0800
Message-ID: <CAC2pzGe9Q+19LpyFPwr8+TZ02XfCqwrQzsEsJA8WWB6XhuJyeQ@mail.gmail.com>
Subject: [PATCH] mm: move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME to file linux/slab.h
From: Bryton Lee <brytonlee01@gmail.com>
Content-Type: multipart/alternative; boundary=001a113801d26152c9050c064c63
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "vger.linux-kernel.cn" <kernel@vger.linux-kernel.cn>

--001a113801d26152c9050c064c63
Content-Type: text/plain; charset=UTF-8

move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME from file mm/slab_common.c
to file linux/slab.h.
let other kernel code create slab can use these flags.

Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
---
 include/linux/slab.h | 11 +++++++++++
 mm/slab_common.c     | 10 ----------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9a139b6..6853f85 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -90,6 +90,17 @@
 /* The following flags affect the page allocator grouping pages by
mobility */
 #define SLAB_RECLAIM_ACCOUNT    0x00020000UL        /* Objects are
reclaimable */
 #define SLAB_TEMPORARY        SLAB_RECLAIM_ACCOUNT    /* Objects are
short-lived */
+
+/*
+ * Set of flags that will prevent slab merging
+ */
+#define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+        SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
+        SLAB_FAILSLAB)
+
+#define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
+        SLAB_CACHE_DMA | SLAB_NOTRACK)
+
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e03dd6f..4f1974b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -31,16 +31,6 @@ DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;

 /*
- * Set of flags that will prevent slab merging
- */
-#define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-        SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-        SLAB_FAILSLAB)
-
-#define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
-        SLAB_CACHE_DMA | SLAB_NOTRACK)
-
-/*
  * Merge control. If this is set then no merging of slab caches will occur.
  * (Could be removed. This was introduced to pacify the merge skeptics.)
  */
-- 
2.0.5



-- 
Best Regards

Bryton.Lee

--001a113801d26152c9050c064c63
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br>move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME from f=
ile mm/slab_common.c to file linux/slab.h.<br>let other kernel code create =
slab can use these flags. <br><br>Signed-off-by: Bryton Lee &lt;<a href=3D"=
mailto:brytonlee01@gmail.com">brytonlee01@gmail.com</a>&gt;<br>---<br>=C2=
=A0include/linux/slab.h | 11 +++++++++++<br>=C2=A0mm/slab_common.c=C2=A0=C2=
=A0=C2=A0=C2=A0 | 10 ----------<br>=C2=A02 files changed, 11 insertions(+),=
 10 deletions(-)<br><br>diff --git a/include/linux/slab.h b/include/linux/s=
lab.h<br>index 9a139b6..6853f85 100644<br>--- a/include/linux/slab.h<br>+++=
 b/include/linux/slab.h<br>@@ -90,6 +90,17 @@<br>=C2=A0/* The following fla=
gs affect the page allocator grouping pages by mobility */<br>=C2=A0#define=
 SLAB_RECLAIM_ACCOUNT=C2=A0=C2=A0=C2=A0 0x00020000UL=C2=A0=C2=A0=C2=A0 =C2=
=A0=C2=A0=C2=A0 /* Objects are reclaimable */<br>=C2=A0#define SLAB_TEMPORA=
RY=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 SLAB_RECLAIM_ACCOUNT=C2=A0=C2=A0=C2=
=A0 /* Objects are short-lived */<br>+<br>+/*<br>+ * Set of flags that will=
 prevent slab merging<br>+ */<br>+#define SLAB_NEVER_MERGE (SLAB_RED_ZONE |=
 SLAB_POISON | SLAB_STORE_USER | \<br>+=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0 SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \<br>+=C2=A0=C2=
=A0=C2=A0 =C2=A0=C2=A0=C2=A0 SLAB_FAILSLAB)<br>+<br>+#define SLAB_MERGE_SAM=
E (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \<br>+=C2=A0=C2=A0=C2=A0 =C2=A0=
=C2=A0=C2=A0 SLAB_CACHE_DMA | SLAB_NOTRACK)<br>+<br>=C2=A0/*<br>=C2=A0 * ZE=
RO_SIZE_PTR will be returned for zero sized kmalloc requests.<br>=C2=A0 *<b=
r>diff --git a/mm/slab_common.c b/mm/slab_common.c<br>index e03dd6f..4f1974=
b 100644<br>--- a/mm/slab_common.c<br>+++ b/mm/slab_common.c<br>@@ -31,16 +=
31,6 @@ DEFINE_MUTEX(slab_mutex);<br>=C2=A0struct kmem_cache *kmem_cache;<b=
r>=C2=A0<br>=C2=A0/*<br>- * Set of flags that will prevent slab merging<br>=
- */<br>-#define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE=
_USER | \<br>-=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 SLAB_TRACE | SLAB_DESTR=
OY_BY_RCU | SLAB_NOLEAKTRACE | \<br>-=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =
SLAB_FAILSLAB)<br>-<br>-#define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_REC=
LAIM_ACCOUNT | \<br>-=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 SLAB_CACHE_DMA |=
 SLAB_NOTRACK)<br>-<br>-/*<br>=C2=A0 * Merge control. If this is set then n=
o merging of slab caches will occur.<br>=C2=A0 * (Could be removed. This wa=
s introduced to pacify the merge skeptics.)<br>=C2=A0 */<br>-- <br>2.0.5<br=
><br><br clear=3D"all"><br>-- <br><div class=3D"gmail_signature">Best Regar=
ds<br><br>Bryton.Lee<br><br></div>
</div>

--001a113801d26152c9050c064c63--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

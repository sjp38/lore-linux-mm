Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F738C742B9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:03:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA94C2083B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:03:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Po5R+v4T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA94C2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C55A8E0141; Fri, 12 Jul 2019 08:03:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89C358E00DB; Fri, 12 Jul 2019 08:03:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73CB78E0141; Fri, 12 Jul 2019 08:03:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA6A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:03:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so5434227pfi.6
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:03:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pG1dMHtZH73TRwIerhkeF5MzPMCfsVBoJ6eMm8ohCck=;
        b=fVRGVrmygI5+gXJANb0EPLxbeivzrqi8WKMFgI7ABOetkCIhqpVGARpu1F7kPG6jdp
         fyy7TGKufjgQ1Ba4gXeMCwj2/ZbwDxEXrgehk2mfQuvj67TMJE0gy+NdtYaAKjB6SKpy
         b5y6bwGcFH/E7cXeC9CCwOt6SM14RBtDaouKPUvsfYB8KlhQNh/4lX6bsJKFwwUdnwPu
         tpPFZMXs/h1q2EL9UnF+RCZuf7tTWkfMPNPCVxB520iiAdYgvq7lEr3LAEhbV9kpAd+1
         Zv6piXlVgkFLElkxJDuXm+loFfAcBwuCavVECkjvHa10Q4360VFfwwKOhojFgiv/DWVN
         C9zA==
X-Gm-Message-State: APjAAAVJXLS2gZHPHZZvQCw6j5J5Rv3yKW7c7DzAPnlgNuenvaJVizBf
	w+rlZIPktwkbI+FPGAyiHmKRqZ1Y9Utau2Wo3EayfkVlLF3ICyiTGMAyw8Xa+q8udil7hMe6hdQ
	xtq8hEqTur61A9QJB6Ut6t6ZTAsyWWlsACF0XZGnasGD14r+zG+klui/jooEgDYN2Vg==
X-Received: by 2002:a17:902:6a85:: with SMTP id n5mr10338882plk.73.1562932992859;
        Fri, 12 Jul 2019 05:03:12 -0700 (PDT)
X-Received: by 2002:a17:902:6a85:: with SMTP id n5mr10338747plk.73.1562932991481;
        Fri, 12 Jul 2019 05:03:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562932991; cv=none;
        d=google.com; s=arc-20160816;
        b=Xk1Kd/i0LHA2md7YEm2Ve/TKWi8f33OyFDH7CcOocXW3OHXN7dFg93tGf4+eB7gnHe
         5107q8gATOeKGJFRyh8oO7048tSQZV/D3ogKeEWhjPwWLwY9jUiCv7Uhz0RNwq0ERFdO
         Q9yqJ3XptMNjuex22g8WuSTVmTq9CFyHpyofAtbxFCmA4gY73XyQXeIXLKEjwIJ9pBTP
         LADGIXuOuclr70kaPu/xp/5Wqygy0fCk/bZN1UUKM5+YgI63azOQqmNZpKydtOYqDZAM
         FJzIEwTdSWPEfZN8OKSpO8qB7BisSutUewgWWKFBtxghdfVhoybbC3erEYcs8Nn400eO
         7BdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pG1dMHtZH73TRwIerhkeF5MzPMCfsVBoJ6eMm8ohCck=;
        b=BtKHnuivK9JTfEaM3OFyRmob1iwxi6kIEMyOSPg8dalKzPIgflVbF1J7lCTPv9IsM4
         0bbpOZ+Vo/1O7yX1XXufVuYh3g1YDfqXqgvX97Tp4FRMJnk4VdsgsvZlkkFQYheazHQK
         t9jtz7dSFVP5PpuU8Z5yrh4F+3VKNoJ/rp/LFki1wm0Qq9rN4sb44mMI/efUmiUuNo6A
         7KD2wCfXG1QzZu9QrvYlJs2SXtAnOWmubHSgT6DCLRHejg5gYm+QKucekCYUBvoxHZXn
         l3qKzVFU30we60B4ZaT6TqVKiVIn1BQ8N3tfWqucs0igakOvnMkaaQKe4aAYrIiBpJln
         /H1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Po5R+v4T;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor4543484pgg.6.2019.07.12.05.03.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 05:03:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Po5R+v4T;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pG1dMHtZH73TRwIerhkeF5MzPMCfsVBoJ6eMm8ohCck=;
        b=Po5R+v4Tq9SSrH6dw19MSifuek7bEwcNoexmrF6UIV5Tic0O540E39uOdiAc+TZekt
         Yg1XDZ8wGwfvTBgfg03ER1ZzIHw1fnAd17nF1igYdadTeCHdMGqxav3ZdjyJ5dcEu4Ll
         +6xvShvyiUWzwC8GpyXvk1jQWe34DEo2q7aA19TOGfWTliGIiTjCJ2/4Do+j3zVIMGSJ
         kdyIv9YZfhODXjrGut8IFHEjEpbWw2A2kFvsW3G+O6LoTv1FscJ4zqyzNuePsfo40fsY
         NPnMmfLu69M433nqOSkZoKaW4WMb0WZQL9Hqn/x4gLADGzjSggjSfef6UOAhbUWRi3Ya
         tIUw==
X-Google-Smtp-Source: APXvYqwah3U58lG/iFfoMWrOCymtN4tLD33/PiCMqjtD3w+TClssgHN7tIvimgRpgIKmVXP41rg6DQ==
X-Received: by 2002:a63:d756:: with SMTP id w22mr10239371pgi.156.1562932991099;
        Fri, 12 Jul 2019 05:03:11 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:478:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a128sm4605496pfb.185.2019.07.12.05.03.04
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 05:03:10 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v4 2/2] mm/vmalloc.c: Modify struct vmap_area to reduce its size
Date: Fri, 12 Jul 2019 20:02:13 +0800
Message-Id: <20190712120213.2825-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190712120213.2825-1-lpf.vector@gmail.com>
References: <20190712120213.2825-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Objective
---------
The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Description
-----------
1) Pack "vm" and "subtree_max_size"
This is no problem because
  A) "vm" is only used when vmap_area is in "busy" tree
  B) "subtree_max_size" is only used when vmap_area is in
     "free" tree

2) Pack "purge_list"
The variable "purge_list" is only used when vmap_area is in
"lazy purge" list. So it can be packed with other variables,
which are only used in rbtree and list sorted by address.

3) Eliminate "flags".
Since only one flag VM_VM_AREA is being used, and the same
thing can be done by judging whether "vm" is NULL, then the
"flags" can be eliminated.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 include/linux/vmalloc.h | 40 +++++++++++++++++++++++++++++++---------
 mm/vmalloc.c            | 28 +++++++++++++---------------
 2 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 9b21d0047710..6fb377ca9e7a 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -51,15 +51,37 @@ struct vmap_area {
 	unsigned long va_start;
 	unsigned long va_end;
 
-	/*
-	 * Largest available free size in subtree.
-	 */
-	unsigned long subtree_max_size;
-	unsigned long flags;
-	struct rb_node rb_node;         /* address sorted rbtree */
-	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
-	struct vm_struct *vm;
+	union {
+		/* In rbtree and list sorted by address */
+		struct {
+			union {
+				/*
+				 * In "busy" rbtree and list.
+				 * rbtree root:	vmap_area_root
+				 * list head:	vmap_area_list
+				 */
+				struct vm_struct *vm;
+
+				/*
+				 * In "free" rbtree and list.
+				 * rbtree root:	free_vmap_area_root
+				 * list head:	free_vmap_area_list
+				 */
+				unsigned long subtree_max_size;
+			};
+
+			struct rb_node rb_node;
+			struct list_head list;
+		};
+
+		/*
+		 * In "lazy purge" list.
+		 * llist head: vmap_purge_list
+		 */
+		struct {
+			struct llist_node purge_list;
+		};
+	};
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9eb700a2087b..1245d3285a32 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -1115,7 +1114,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	va->va_start = addr;
 	va->va_end = addr + size;
-	va->flags = 0;
+	va->vm = NULL;
 	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 
 	spin_unlock(&vmap_area_lock);
@@ -1279,7 +1278,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
 		unsigned long nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
 
-		__free_vmap_area(va);
+		merge_or_add_vmap_area(va,
+			&free_vmap_area_root, &free_vmap_area_list);
+
 		atomic_long_sub(nr, &vmap_lazy_nr);
 
 		if (atomic_long_read(&vmap_lazy_nr) < resched_threshold)
@@ -1919,7 +1920,6 @@ void __init vmalloc_init(void)
 		if (WARN_ON_ONCE(!va))
 			continue;
 
-		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
@@ -2017,7 +2017,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
-	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
 }
 
@@ -2122,10 +2121,10 @@ struct vm_struct *find_vm_area(const void *addr)
 	struct vmap_area *va;
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA)
-		return va->vm;
+	if (!va)
+		return NULL;
 
-	return NULL;
+	return va->vm;
 }
 
 /**
@@ -2146,11 +2145,10 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 	spin_lock(&vmap_area_lock);
 	va = __find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
+	if (va && va->vm) {
 		struct vm_struct *vm = va->vm;
 
 		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -2853,7 +2851,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -2933,7 +2931,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -3463,10 +3461,10 @@ static int s_show(struct seq_file *m, void *p)
 	va = list_entry(p, struct vmap_area, list);
 
 	/*
-	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
-	 * behalf of vmap area is being tear down or vm_map_ram allocation.
+	 * If !va->vm then this vmap_area object is allocated
+	 * by vm_map_ram.
 	 */
-	if (!(va->flags & VM_VM_AREA)) {
+	if (!va->vm) {
 		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
 			(void *)va->va_start, (void *)va->va_end,
 			va->va_end - va->va_start);
-- 
2.21.0


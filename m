Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64EF4C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1318420665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 14:16:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="niR9yO0Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1318420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B322B8E0008; Tue,  2 Jul 2019 10:16:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B09468E0001; Tue,  2 Jul 2019 10:16:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D05F8E0008; Tue,  2 Jul 2019 10:16:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 628C88E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 10:16:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i13so1036443pgq.3
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 07:16:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CO1HonlQmPbMkXDhRXg7GyAorrH54gcigaOJMEfOSWg=;
        b=iBUD+lfrphuu5v784jRforRu8meCdBn410Uav3/cBreGT2SnbuDVNKTkz90Rpfb33s
         tAoP0DJCnZg92iRdxRfcvpoDIm0mtMj2wDOoFns2ZPZS1SkXg+rMCKHDaOpfHFcs8Y+7
         iWwNMsX7jB0j4kOhQG/fY8WuUHYhiqNfUNFyJ5VkV8GBsiZiHaGMbxMHr5edMnV+zn2H
         1947zjIM/o85ZPdycBnnJ1S7JK7YHbANMB+uEdeyG6qQScq5mkEwrXKQ3gsFYOpqzRe0
         B/OKsgKlfDD6PaMiD5bDRKzcouRwHW/MymOtZCT5QC1vcFM1K8ZIdj2TjQooLdbcfqHI
         0bjw==
X-Gm-Message-State: APjAAAW5TJrzIEZxisketqg5dQ+Y42Hh95LkHGLntRC6T56WEG22+V2a
	ktWaJoGZn6qR7c2NFNGpxxRc6VoFCHxNRen8T5e1hKGMkORLCNjYptX/t8J+bteRkFGjR54NHZe
	1QpOKZ7O3haJJoKq3tSdD5xjMXxaIPRz1Dl+ziIbq/pIKZuVEW/S7NMcTxr3htYHfhA==
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr35333954plt.152.1562077010032;
        Tue, 02 Jul 2019 07:16:50 -0700 (PDT)
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr35333863plt.152.1562077008944;
        Tue, 02 Jul 2019 07:16:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562077008; cv=none;
        d=google.com; s=arc-20160816;
        b=H8Y9fLMK3TBEOfrNniq6MDE6O4bINp89Z2BuSW2/5RyGg+FLKSXnA2BtRSOlbbX7Bt
         wHkIYWPwbhZodSDMJac3xP8m0sOcBRAv7k2S3YS096nbK0MHCiTCmtxdW40kah+cQDBh
         pAKVngT6q3S/r2Lzfc5CoNP6DqGVG+v7f4dP4Cv+tjbQz6kGP2FGe0FRwltNlzezxpfm
         xDGC3QPAQjR4D792JrqmUl/obQtNknr8DbPP2ipT7HBPFI038S36PDqLhNiRULByFx87
         2QS4R6JV0G2djuNoN0raOThsOVfk6bG7o0jPeNKfj7LgFimjSPmCm5OSWKuemZiImO1w
         qdlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CO1HonlQmPbMkXDhRXg7GyAorrH54gcigaOJMEfOSWg=;
        b=t7lrgD5vQU0LKhGMCFSUkKiYolIsLcqk7p3IgJuKrz3OLFyAlcdBDjGP8Qzq7XjjLS
         /flJ4T+6gZx1/uxFCKezhNTIctyROztmFM1fDW/vKjFbJ97kNWWgy/zRFD1i6kU8c2Ql
         0mwelND5m7YyIZc4EiZrt7AUB7d8/MY9XLgqDpvRyLeonGd5uePjIEAoJifNGpWskDxa
         /cUA8i1mEXCzkdOfFa32YIlcn+aneebQUjRL4eoEnAL0PaeY7rOU7M/GPYaR1jw4wq8o
         ivcjMs9B7ckt5SBq9iXVa3rgXVwiI8VP7z6EgjLPvxdlxWH1FLji/1YeK41qG2HkXgcd
         tC6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=niR9yO0Y;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a20sor6575963pgm.3.2019.07.02.07.16.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 07:16:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=niR9yO0Y;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=CO1HonlQmPbMkXDhRXg7GyAorrH54gcigaOJMEfOSWg=;
        b=niR9yO0Y/6o7iMNZeCRrGiwL+NCvbnvMkK++I7yQezM12HqY5Om9yRWzwzgpOmCDzp
         3sb9lK454kLeAXM7oZsP6/OtTazGiNWNT542jvQbXsmwSzMkrTMcnUeH6Qe1AnilDLBf
         AdcBWSskv9foofZdhLVVJVy4K+EuA7/Ar2r7m4tcJJt+aTsY5ooeib84iEsF5Fg4bdpT
         rkBatzipJ/lY2NhGYA+TwY3w+A4cIACybC+cUjGRoZFC0I0tJc2IxerM2y47NnVm9Q3l
         5fsPC2Otl/tgrUKoI/pt5S00yDdQYqFWd51+Fz+6xrrmS5QppxCxm0pcKF3FU3oFc5Ft
         uLxQ==
X-Google-Smtp-Source: APXvYqzJbwkaxbHtL6VK4vg0aa1y5tweDY+u4FYqKxaFH2XhqHmwVbU5lZzvniumVZ6N9r+MAq6xPg==
X-Received: by 2002:a63:c508:: with SMTP id f8mr50576pgd.48.1562077008475;
        Tue, 02 Jul 2019 07:16:48 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a5sm744617pjv.21.2019.07.02.07.16.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 07:16:48 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 5/5] mm/vmalloc.c: Rewrite struct vmap_area to reduce its size
Date: Tue,  2 Jul 2019 22:15:41 +0800
Message-Id: <20190702141541.12635-6-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190702141541.12635-1-lpf.vector@gmail.com>
References: <20190702141541.12635-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Objective
---------
The current implementation of struct vmap_area wasted space. At the
determined stage, not all members of the structure will be used.

For this problem, this commit places multiple structural members that
are not being used at the same time into a union to reduce the size
of the structure.

And local test results show that this commit will not hurt performance.

After applying this commit, sizeof(struct vmap_area) has been reduced
from 11 words to 8 words.

Description
-----------
Members of struct vmap_area are not being used at the same time.
For example,
(1)members @flags, @purge_list, and @vm are unused when vmap area is
in the *FREE* tree;

(2)members @subtree_max_size and @purge_list are unused when vmap area is
in the *BUSY* tree and not in the purge list;

(3)members @subtree_max_size and @vm are unused when vmap area is
in the *BUSY* tree and in the purge list.

Since members @subtree_max_size, @purge_list and @vm are not used
at the same time, so they can be placed in a union to reduce the
size of struct vmap_area.

Besides, since PAGE_ALIGNED(va->va_start) is always true, then @flags and
@va_start can be placed in a union, and @flags use bits below PAGE_SHIFT.
After that, the value of @va_start can be corrected by masking @flags.

Performance Testing
-------------------

Test procedure
--------------

Test result
-----------
(1)Base		(5.2.0-rc7)
Test items			round_1		round_2		round_3
fix_size_alloc_test		596666 usec	600600 usec	597993 usec
full_fit_alloc_test		632614 usec	623770 usec	633657 usec
long_busy_list_alloc_test	8139257 usec	8162904 usec	8234770 usec
random_size_alloc_test		4332230 usec	4335376 usec	4322771 usec
fix_align_alloc_test		1184827 usec	1133574 usec	1148328 usec
random_size_align_alloc_test	1459814 usec	1467915 usec	1465112 usec
pcpu_alloc_test			92053 usec	93290 usec	92439 usec

(2)Patched	(5.2.0-rc7 + this series of patches)
Test items			round_1		round_2		round_3
fix_size_alloc_test		607753 usec	602034 usec	584153 usec
full_fit_alloc_test		593415 usec	627681 usec	634853 usec
long_busy_list_alloc_test	8038797 usec	8012176 usec	8152911 usec
random_size_alloc_test		4304070 usec	4327863 usec	4588769 usec
fix_align_alloc_test		1122373 usec	1108628 usec	1145592 usec
random_size_align_alloc_test	1449265 usec	1475160 usec	1479629 usec
pcpu_alloc_test			93856 usec	91697 usec	92658 usec

(3) Average comparison
Test items			Avg_base		Avg_patched
fix_size_alloc_test		598419.6667 usec	597980.0000 usec
full_fit_alloc_test		630013.6667 usec	618649.6667 usec
long_busy_list_alloc_test	8178977.0000 usec	8067961.3333 usec
random_size_alloc_test		4330125.6667 usec	4406900.6667 usec
fix_align_alloc_test		1155576.3333 usec	1125531.0000 usec
random_size_align_alloc_test	1464280.3333 usec	1468018.0000 usec
pcpu_alloc_test			92594.0000 usec		92737.0000 usec

(4) Percentage difference
Test items			(Avg_base - Avg_patched) / Avg_base
fix_size_alloc_test		0.0735%
full_fit_alloc_test		1.8038%
long_busy_list_alloc_test	1.3573%
random_size_alloc_test		-1.7730%
fix_align_alloc_test		2.6000%
random_size_align_alloc_test	-0.2553%
pcpu_alloc_test			-0.1544%

Result analysis
---------------
Because the test results vary within a range, we can conclude that this
commit does not cause a significant impact on performance.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/vmalloc.h | 28 ++++++++++----
 mm/vmalloc.c            | 82 +++++++++++++++++++++++++++++++++--------
 2 files changed, 87 insertions(+), 23 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..bc23d59cf5ae 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -48,18 +48,30 @@ struct vm_struct {
 };
 
 struct vmap_area {
-	unsigned long va_start;
+	union {
+		unsigned long va_start;
+		/*
+		 * Only used when vmap area is in the *BUSY* tree
+		 * and not in the purge_list.
+		 */
+		unsigned long flags;
+	};
+
 	unsigned long va_end;
 
-	/*
-	 * Largest available free size in subtree.
-	 */
-	unsigned long subtree_max_size;
-	unsigned long flags;
+	union {
+		/* Only used when vmap area is in the *FREE* tree */
+		unsigned long subtree_max_size;
+
+		/* Only used when vmap area is in the vmap_purge_list */
+		struct llist_node purge_list;
+
+		/* Only used when the VM_VM_AREA flag is set */
+		struct vm_struct *vm;
+	};
+
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
-	struct vm_struct *vm;
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ad117d16af34..c7e59bc54024 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,8 +329,50 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_LAZY_FREE	0x02
-#define VM_VM_AREA	0x04
+
+/*
+ * For vmap area in the *BUSY* tree, PAGE_ALIGNED(va->va_start)
+ * is always true.
+ * This is guaranteed by calling BUG_ON(offset_in_page(size))
+ * and BUG_ON(!PAGE_ALIGNED(addr)).
+ * So define MAX_VA_FLAGS_SHIFT as PAGE_SHIFT.
+ */
+#define MAX_VA_FLAGS_SHIFT		PAGE_SHIFT
+
+enum VA_FlAGS_TYPE {
+	VM_VM_AREA = 0x1UL,
+
+	/*
+	 * The value of newly added flags should be between
+	 * VM_VM_AREA and LAST_VMAP_AREA_FLAGS.
+	 */
+
+	LAST_VMAP_AREA_FLAGS = (1UL << MAX_VA_FLAGS_SHIFT)
+};
+
+#define VMAP_AREA_FLAGS_MASK		(~(LAST_VMAP_AREA_FLAGS - 1))
+
+/*
+ * va->flags should be set with this helper function to ensure
+ * the correctness of the flag being set, instead of directly
+ * modifying the va->flags.
+ */
+static __always_inline void
+set_va_flags(struct vmap_area *va, enum VA_FlAGS_TYPE flag)
+{
+	BUILD_BUG_ON(!is_power_of_2(flag));
+
+	BUILD_BUG_ON(flag >= LAST_VMAP_AREA_FLAGS);
+
+	va->flags |= flag;
+}
+
+/* Return the correct value of va->va_start by masking flags */
+static __always_inline unsigned long
+get_va_start(struct vmap_area *va)
+{
+	return (va->va_start & VMAP_AREA_FLAGS_MASK);
+}
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -399,6 +441,11 @@ static void purge_vmap_area_lazy(void);
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 static unsigned long lazy_max_pages(void);
 
+/*
+ * va->va_start may contain the value of flags when vmap area is in
+ * the *BUSY* tree, so use the helper function get_va_start() to get
+ * the value of va_start instead of directly accessing it.
+ */
 static struct vmap_area *__search_va_in_busy_tree(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -407,7 +454,7 @@ static struct vmap_area *__search_va_in_busy_tree(unsigned long addr)
 		struct vmap_area *va;
 
 		va = rb_entry(n, struct vmap_area, rb_node);
-		if (addr < va->va_start)
+		if (addr < get_va_start(va))
 			n = n->rb_left;
 		else if (addr >= va->va_end)
 			n = n->rb_right;
@@ -454,9 +501,9 @@ find_va_links(struct vmap_area *va,
 		 * or full overlaps.
 		 */
 		if (va->va_start < tmp_va->va_end &&
-				va->va_end <= tmp_va->va_start)
+				va->va_end <= get_va_start(tmp_va))
 			link = &(*link)->rb_left;
-		else if (va->va_end > tmp_va->va_start &&
+		else if (va->va_end > get_va_start(tmp_va) &&
 				va->va_start >= tmp_va->va_end)
 			link = &(*link)->rb_right;
 		else
@@ -1079,8 +1126,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	va->va_start = addr;
 	va->va_end = addr + size;
-	va->flags = 0;
 	insert_va_to_busy_tree(va);
+	va->vm = NULL;
 
 	spin_unlock(&vmap_area_lock);
 
@@ -1872,11 +1919,12 @@ void __init vmalloc_init(void)
 		if (WARN_ON_ONCE(!va))
 			continue;
 
-		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
-		va->vm = tmp;
 		insert_va_to_busy_tree(va);
+
+		set_va_flags(va, VM_VM_AREA);
+		va->vm = tmp;
 	}
 
 	/*
@@ -1969,8 +2017,10 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
+
+	set_va_flags(va, VM_VM_AREA);
 	va->vm = vm;
-	va->flags |= VM_VM_AREA;
+
 	spin_unlock(&vmap_area_lock);
 }
 
@@ -2102,9 +2152,11 @@ struct vm_struct *remove_vm_area(const void *addr)
 		struct vm_struct *vm = va->vm;
 
 		spin_lock(&vmap_area_lock);
-		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
+		/*
+		 * Restore the value of va_start by masking flags
+		 * before adding vmap area to the purge list.
+		 */
+		va->va_start = get_va_start(va);
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -3412,9 +3464,9 @@ static int s_show(struct seq_file *m, void *p)
 	 */
 	if (!(va->flags & VM_VM_AREA)) {
 		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
-			(void *)va->va_start, (void *)va->va_end,
-			va->va_end - va->va_start,
-			va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
+			(void *)get_va_start(va), (void *)va->va_end,
+			va->va_end - get_va_start(va),
+			va->vm ? "unpurged vm_area" : "vm_map_ram");
 
 		return 0;
 	}
-- 
2.21.0


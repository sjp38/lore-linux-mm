Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08EA4C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF36C20C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:30:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j01UzZa+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF36C20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E45E8E0015; Mon, 25 Feb 2019 15:30:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5945F8E000C; Mon, 25 Feb 2019 15:30:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 482798E0015; Mon, 25 Feb 2019 15:30:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 061DF8E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:30:45 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y1so7873156pgo.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:30:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=omgUtD5TBe/L2nj/vYLxBbkyge+zjnwluovkZCUWzAA=;
        b=SufsNJ3DMQL1V8Mb5jTvO8Bw7qWubWpXYmnUdHDmWDJxv7jhkFDsqohCfqvAb3rmdt
         WJostYdguERHkg+5CYZpD+Ke3/aCOfW0ZTXKTc58u65nPmp7b4s3c+xnAeLzO6+7UzvV
         eQNXKQ1oVHxvYwaPp6Ez1LM/HCDH7pBLQ1MHw9xzyWyitpKLA7YBnMtTcSnRO5VsHfnC
         KF/A+DscgZZy/NpVnrBtjk6+unvHns/lOV5B/1k4hBzGmNAQQzw8RZFCVzZczB6YdGDO
         CZ/cfvfUFwg9B0zW/2rPLteNrlw6BVvjCzjNOgOX/Zu3OifNAySUXKd++0aiZkS7qbBK
         WPzg==
X-Gm-Message-State: AHQUAua3Jt9+DY4gWZAI3YdPQLF+WQF7OmGcNkjHKfOYgDaOm39Zv3yC
	fYd898pua1Q30Tm2apkS7VyR73atssCW2gXpe7tZVLpHWXfGojOAZ7go19FbMnQv9Nverx6VLXE
	rzshsUYM8nJtB8yr3iYVBgzxQrUv0KI4HyQeebFr3nSIMQgf+QuYnNhSc8A3N7ksYKOXuz6xxB9
	opmZr4/5FPFTuXEzGq0yZzJU0qClkmZx+djq9sCxjcyD6wW/QeKqMf5sEfd25kFDsp0lJPsz3SN
	LTulTIf6fho+nO/3DqWzHMI/s05Wkf4Q7Dml3pwcsEm8R8GJkh/DJZ9ObJc994YBMbn8LD5uRIN
	QNzPxO8jSwmQ4wqcmesHUcIHbunU/cRuOE8dddOpCedw5yvRnI5d01RNsA3F0GqaU/r5lEp+zCy
	w
X-Received: by 2002:a63:6a08:: with SMTP id f8mr20980296pgc.165.1551126644647;
        Mon, 25 Feb 2019 12:30:44 -0800 (PST)
X-Received: by 2002:a63:6a08:: with SMTP id f8mr20980231pgc.165.1551126643615;
        Mon, 25 Feb 2019 12:30:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551126643; cv=none;
        d=google.com; s=arc-20160816;
        b=qLXL0SQFX+216qhqVxo2OnUd/8Tirr5StMzpyb/rVIXZFv0DwYhNl2wA8e10QOFLG3
         QwSBlof0AILcdFKgN7aQXezGn030aH+yhtFhUZ7mJBzJTrr8IEkuhqkjOSUcTw30qdPO
         nrbTNfpLEcSzWlmegzB0pWLK6LAtwXoDIGG+dUKnZaszynrySjYrkZW0CD3zap4lrNne
         8UjrdXiMJ1d2TUymkXeBQvfVZ6Ax+lX0/otN5TThGhmjMWWZxao/i1594jYE5a+zxnu/
         j/Z/Rx6pY5oJ7NI827cK1i8Gsrzcyw+aItoJFv1ystS8pqi+pjeO6Ykg+7LFo+EJ1RsI
         kJPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=omgUtD5TBe/L2nj/vYLxBbkyge+zjnwluovkZCUWzAA=;
        b=cu+qJPM2yDUTDhbnJeP2trm539eqcNJ4focvQgN9Fk8u0F0QrYgnM3kBrAi/Q1TlIL
         wrP+br2OjgBwu9egzC1JVKQeKB5H6ZE4f0gW8eqZtZ+UZ1gfLWudBSwYuRVuM5PNQyKo
         XcFcevlNeik6wUlQLxt0cH4pPrwE0+L0EmI+Em5eSeLjV3jF7NyAELlkbgugSRpuvYA4
         AN8ZcZwVmplygdtLvEc+9lbWVgBL7ZG1CpNTG54nQ508aYiHert1qCBEPXLe0L8V6Hn8
         v390e9nehpJiC6yCl2E7RjP0FDYpYhBdfsWFTPVHaig0xBhcap6T7h/TgRlAvSmcaCOJ
         ZWFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=j01UzZa+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r21sor15622978pgl.58.2019.02.25.12.30.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:30:43 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=j01UzZa+;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=omgUtD5TBe/L2nj/vYLxBbkyge+zjnwluovkZCUWzAA=;
        b=j01UzZa+id2m/gN68bYEvZ2TcacRml0G75125G0/K1Kc15uFzc3+eHRhm1GmJEPo+e
         bPF9giJM+jYKBhNa9ilvHZMTDP415am/itTmB4YZk2mpSNJEgaB0ac9bgWe526icGmQ3
         5pNWwng9d1sC54oP81jbGJcHQNydL1WDOFZZETK9SecOJ2m56LI8c00vPW/5g0fuHn3A
         WFMDwylnTqVdmI9DCdMcsUyQosnLd6M3xVfIF2TCJvR7ojKoeO7R5cWZYoJu8ZJsLTno
         m6fH64U8YFtpe+mEei0jx39diwnfLPvE9aPYSSOIP3ARIIKMXV9eizsPB8doAiOD73xn
         4Yww==
X-Google-Smtp-Source: AHgI3IbE9OLfOBUyZf9WhRChQMHXzfN8ZG5LJLKgkPJ0+6R2i4vCAr2MYtrIjYsBQogBmMKSDHzM9A==
X-Received: by 2002:a63:8bc8:: with SMTP id j191mr19599469pge.234.1551126643113;
        Mon, 25 Feb 2019 12:30:43 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d960])
        by smtp.gmail.com with ESMTPSA id s4sm6189885pfe.16.2019.02.25.12.30.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:30:42 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/3] mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
Date: Mon, 25 Feb 2019 12:30:35 -0800
Message-Id: <20190225203037.1317-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225203037.1317-1-guro@fb.com>
References: <20190225203037.1317-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__vunmap() calls find_vm_area() twice without an obvious reason:
first directly to get the area pointer, second indirectly by calling
remove_vm_area(), which is again searching for the area.

To remove this redundancy, let's split remove_vm_area() into
__remove_vm_area(struct vmap_area *), which performs the actual area
removal, and remove_vm_area(const void *addr) wrapper, which can
be used everywhere, where it has been used before.

On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
of 4-pages vmalloc blocks.

Perf report before:
  22.64%  cat      [kernel.vmlinux]  [k] free_pcppages_bulk
  10.30%  cat      [kernel.vmlinux]  [k] __vunmap
   9.80%  cat      [kernel.vmlinux]  [k] find_vmap_area
   8.11%  cat      [kernel.vmlinux]  [k] vunmap_page_range
   4.20%  cat      [kernel.vmlinux]  [k] __slab_free
   3.56%  cat      [kernel.vmlinux]  [k] __list_del_entry_valid
   3.46%  cat      [kernel.vmlinux]  [k] smp_call_function_many
   3.33%  cat      [kernel.vmlinux]  [k] kfree
   3.32%  cat      [kernel.vmlinux]  [k] free_unref_page

Perf report after:
  23.01%  cat      [kernel.kallsyms]  [k] free_pcppages_bulk
   9.46%  cat      [kernel.kallsyms]  [k] __vunmap
   9.15%  cat      [kernel.kallsyms]  [k] vunmap_page_range
   6.17%  cat      [kernel.kallsyms]  [k] __slab_free
   5.61%  cat      [kernel.kallsyms]  [k] kfree
   4.86%  cat      [kernel.kallsyms]  [k] bad_range
   4.67%  cat      [kernel.kallsyms]  [k] free_unref_page_commit
   4.24%  cat      [kernel.kallsyms]  [k] __list_del_entry_valid
   3.68%  cat      [kernel.kallsyms]  [k] free_unref_page
   3.65%  cat      [kernel.kallsyms]  [k] __list_add_valid
   3.19%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
   3.10%  cat      [kernel.kallsyms]  [k] find_vmap_area
   3.05%  cat      [kernel.kallsyms]  [k] rcu_cblist_dequeue

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@infradead.org>
---
 mm/vmalloc.c | 47 +++++++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b7455d4c8c12..8f0179895fb5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1477,6 +1477,24 @@ struct vm_struct *find_vm_area(const void *addr)
 	return NULL;
 }
 
+static struct vm_struct *__remove_vm_area(struct vmap_area *va)
+{
+	struct vm_struct *vm = va->vm;
+
+	might_sleep();
+
+	spin_lock(&vmap_area_lock);
+	va->vm = NULL;
+	va->flags &= ~VM_VM_AREA;
+	va->flags |= VM_LAZY_FREE;
+	spin_unlock(&vmap_area_lock);
+
+	kasan_free_shadow(vm);
+	free_unmap_vmap_area(va);
+
+	return vm;
+}
+
 /**
  * remove_vm_area - find and remove a continuous kernel virtual area
  * @addr:	    base address
@@ -1489,31 +1507,20 @@ struct vm_struct *find_vm_area(const void *addr)
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
+	struct vm_struct *vm = NULL;
 	struct vmap_area *va;
 
-	might_sleep();
-
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
-		struct vm_struct *vm = va->vm;
-
-		spin_lock(&vmap_area_lock);
-		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
-		spin_unlock(&vmap_area_lock);
-
-		kasan_free_shadow(vm);
-		free_unmap_vmap_area(va);
+	if (va && va->flags & VM_VM_AREA)
+		vm = __remove_vm_area(va);
 
-		return vm;
-	}
-	return NULL;
+	return vm;
 }
 
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
+	struct vmap_area *va;
 
 	if (!addr)
 		return;
@@ -1522,17 +1529,18 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = find_vm_area(addr);
-	if (unlikely(!area)) {
+	va = find_vmap_area((unsigned long)addr);
+	if (unlikely(!va || !(va->flags & VM_VM_AREA))) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
 		return;
 	}
 
+	area = va->vm;
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	__remove_vm_area(va);
 	if (deallocate_pages) {
 		int i;
 
@@ -1547,7 +1555,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	}
 
 	kfree(area);
-	return;
 }
 
 static inline void __vfree_deferred(const void *addr)
-- 
2.20.1


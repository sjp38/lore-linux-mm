Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11374C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C0020869
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:57:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QCGXaJM2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C0020869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 754088E0002; Tue, 12 Feb 2019 12:57:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 703708E0001; Tue, 12 Feb 2019 12:57:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F2DF8E0002; Tue, 12 Feb 2019 12:57:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 207FB8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:57:18 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w20so2717647ply.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:57:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=93OAZAKUmkpYvDgCLiiRT27o1RpTSM6guTV/d2KLbuo=;
        b=cJ+XABE4RoUX6aiSm2AFwLtasnfNMLSHiEXJlfDtSEN+eujS30AHN/+o3yypDscgU0
         0YJ705ijeUw5iR3I0a7RYwFdTWs4g/2dpQ2KF36C5ECtfWt62tiRDfKlUgNIhLnjdpRX
         EtQE73ETdVtG1YdF9vxTAzSzFR44CbwtChNE58ChKFTIh3IjM5FzU0uO4IWMO+lADJY0
         GZzNlHUdWV+F1/tP41lhblt+we6yfgIIiLseYPL+/+Lp1muqY/I38UBXaOzHq30P34h6
         6euw907ICTyPsLAOTLNNXGsaoR6m/M4ChUCjg4afjfxOF3vK1QuZvpq0nf+/uThggnt4
         lx/g==
X-Gm-Message-State: AHQUAuba32EPftyd+W8LbbAP5Y2/+vM5AdAoMUAwYXu546hWwbD7sLnQ
	uHczibg/KCZCyLxOsitxZVU32MDnSKkM1FY0f8YjFmzYrWucVUE/UNTwHWxP3oeMf1gEvJWjpDj
	sVCU50ssBVrd4F4HF1IybigEQ+4hD26hsqethc/LsEp+O/u0ZEdi/bMBsTRwx8AQRY9G7xn0CJK
	12IBb+ObqkuO7+Qj99StkRQx309gNUXSC+Hu07BzN/0G2BcnuB9VcJLyOCqKklVXQKuAws8/Ktd
	lF1VMEOHFg7Q7ePY2KpQIVGlhhofPljvTG5n6kqvrV2N0dQFj6FOu1DyGt7f444BiJTx9DE4FH6
	xlo5KBZxuQzGfY+sC/vkA/RVLBrv9D55U1Vs8zoQ8I5jZAYbB3KQ4tIpzoQNKIwq7HrJN4Ful2o
	v
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr5292076plb.51.1549994237700;
        Tue, 12 Feb 2019 09:57:17 -0800 (PST)
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr5292038plb.51.1549994236943;
        Tue, 12 Feb 2019 09:57:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994236; cv=none;
        d=google.com; s=arc-20160816;
        b=YnIPp8p0vbf0TV4/Lezt54bqEIOVcJKuV0Bs+1s/JHcRYVf4sKx9wLYm6oDl3EY6sh
         8IHqGdDkmjAEIz9HWuevCvHkyquRPefh7x/NoaElk4OTWlvwfpcBr/Xo9t52EO+duKpt
         rmKGs5oYblb6aCVlYu+9FqgKeTNXhMkOP/e5EYbtp4Pfne6JbYR+jy35he2Ylpdu8+ec
         6kTUhk7N+hQtnR/l4LOEQNuj+/Oaz7AyjZSB0Z7N/gwQo3D1jIIZWxGSHHK5eYWUHnZK
         SKOLagtw7SvYIqgPy/qtbRX3T75t1G9aHdSzitijGIBP0ZNH929ZE4bXDRleZV7uRuPJ
         OYvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=93OAZAKUmkpYvDgCLiiRT27o1RpTSM6guTV/d2KLbuo=;
        b=qbWmo276u1FueEhh8H34btnMKk0npE1qDXoN6/JacuvfLWqt7Hkt/ebFbvQuzdT57J
         u4j6L2aaqyQvT1JJzluHhZ9aLw3iB1m33SnQYqa+44fbHjgtcP5huJ6W8Gvms4O/cir6
         m5kRQOeGT/AavR1I1uWMJ/8jHI/7hz4odzEPGKaPMQ0fvY5eHfpsTBL7ONdJJSHfMLhS
         xuym60MaerUYiljz8KsBoMIMnEXPxhyv0sK0SDwFTnLHQvwotJG/Ln0sgKAefEz61ded
         4txzOrCEaCIcOBjxWpT6r8681qDKMxV6yEFhMOIxVP3B5qOQ76SnMMQXSNUARHrbAQzj
         teug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QCGXaJM2;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor13757828plo.73.2019.02.12.09.57.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 09:57:16 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QCGXaJM2;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=93OAZAKUmkpYvDgCLiiRT27o1RpTSM6guTV/d2KLbuo=;
        b=QCGXaJM2hZZokK7yOMpTLoWcdJNyPFmRc21nwx+XYJj7UgFF+4IibYRea/KVv3ZX8c
         8JX53r9R78lt/ndj5qADE9ryXZzv0gfWL9C0CDRozNeMTN3mo6D/V5Vk3KXHmiLYZJHS
         +kPGtC/3cmiCB718Tj0itOFo4U6RwAnZtulKgLIXt7eYnd17h2kjyeQ/fHvu2qSPqG9M
         +hRIsHipg4Cjpd1Wju20iuBLziYb4UH/o9hmAf/hxuy+llEbnOB1v4dwk8gm5FvWROL2
         aUmqZWfujJ7MKlJpZbi2RA8r8VlJtiSfkJFER/AA0m/HBT/8iEyWkygcjFbRLGwFmGI4
         IVhQ==
X-Google-Smtp-Source: AHgI3IbR1QARiQM372qVa41Na+Ijx46rJgy765Pia3Oe3eVsWoU2m3AYeLeFpsuP9V7WXRuErsrY7Q==
X-Received: by 2002:a17:902:243:: with SMTP id 61mr4968727plc.249.1549994236475;
        Tue, 12 Feb 2019 09:57:16 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::5:4d62])
        by smtp.gmail.com with ESMTPSA id z186sm18608427pfz.119.2019.02.12.09.57.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 09:57:15 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	kernel-team@fb.com,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 1/3] mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
Date: Tue, 12 Feb 2019 09:56:46 -0800
Message-Id: <20190212175648.28738-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212175648.28738-1-guro@fb.com>
References: <20190212175648.28738-1-guro@fb.com>
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


Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6381C5B57E
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89F53208E3
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 07:57:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rSCmPaA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89F53208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2739B6B0005; Sun, 30 Jun 2019 03:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FD978E0003; Sun, 30 Jun 2019 03:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C4A68E0002; Sun, 30 Jun 2019 03:57:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f205.google.com (mail-pf1-f205.google.com [209.85.210.205])
	by kanga.kvack.org (Postfix) with ESMTP id CAD9F6B0005
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 03:57:29 -0400 (EDT)
Received: by mail-pf1-f205.google.com with SMTP id u21so6704341pfn.15
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=gEWlufj6BCoMgC0MdAIs/3gMLDI9D61a2SXbD5zRhBa9djIztwJ+DSZhKCx+Am1d6l
         flUjaAlNvrNEzkGrELu1p6H2akpPaSHWGnDDtU9FAkIyIsRV8la86UWl0wEJPUJM5KQ/
         2Zsy8yG3r4MaCR7CGAMRbD94y5eOgU3sUmiTjHpUROJ1BvwgwpHyrkJ4yuFG80FIYja1
         p448X+D+e/hoOa877cNqtn+vQXJjccgANSI5rjATcA44ywFBRUJQpQFmDSic8WuLNOiZ
         nnITK/3iuKrJnDfizlsVu7W7ZgXhPUi1oMVP3irdgdEkobf3cAM2HPIAno5cTS/gQhlW
         oNrw==
X-Gm-Message-State: APjAAAVcGOUpBKJzUDwWeeDmnhkqjsK5H3cy5Ux+iPgo+FK044qtIrBW
	SpBEN8TSAY4GxQm/pE8AqMMFFE9SeAFZjTQelyjb4RExG4nRAbT3Kj5cbY/QVW7Y5fNQHSPUY7x
	XlHI450iG98evHqcv1jPVupqE4VZ0LtYnJl0TDP8GMcW40MeUg457Lldj4hg134bk7g==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr23737262pjb.30.1561881449495;
        Sun, 30 Jun 2019 00:57:29 -0700 (PDT)
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr23737212pjb.30.1561881448420;
        Sun, 30 Jun 2019 00:57:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561881448; cv=none;
        d=google.com; s=arc-20160816;
        b=eRpXvU5mlmCBh5TShfvnb1o7JlciR2c74eHvWapOH3gWwbbhGoUvU8XDi0v96MLYQn
         lZseHfQWlxfHwyUypDZ1xAlmDw+H837HqVbkYDku5xOVEGBkOhRtSmKDTwtbJxXKKGLU
         1imBqIhO3DFhxlhpOBNi/eO+bAH7aokwbiJV4UFJKb9H+qp8mj64sGLjdwJwedH54KHj
         cHUR4l7sPilvKSq3/hjKOKtEuwfZl5NWQelh7m0Y5mf3J2XQXk15hCv8MFElj1MhulcB
         wSnform9bHyv4g/j1EHD9z3EZ00sMcn3bmv63Pjs+AC3yXxMdihdK9Cze3ZpbBy7LmVR
         d6vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=ob8KSUCldJeANkeSyTZN7jBXzkXjkB6ELQ4dAFH5Cp5uSEBYOnsIB1+QAUqDT4mNVi
         iuMMrNHH9OqXJzQ34JlH8Vvwb9/zjzgj4M/EtyfYQwspn02tbBvxSuP0Ue4B03ba94Sj
         2h08nVOk/SLSORAwwVamR+LyUHVmXZ4DSK00YajmqKZ6LxcU4uqXYhdFCNEeMxb4qxl2
         G2wOOy/gDcvzs07ezoUTn400izfYdMAjFLNFRUPRHQRRHrWBAuMYKnRHD1QBto68PBWY
         3h+tSocHiDkqXP8ND9p+Wo7T09g2Ww1Jce/p60fSjXw3KwqjdG6vJgKAtX7Lyw0gNF9M
         y9Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rSCmPaA3;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor8219047pju.23.2019.06.30.00.57.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 00:57:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rSCmPaA3;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pe03FkrBdknzSMi1BJ7D2IonOmPOSw8u72ZV3zS67vk=;
        b=rSCmPaA3Tt5oSbR8YeEqZLqTU9wKXjxK3j8JcnuFn/CLgYMKlAe8T2yM5V2VuoxHpU
         +PFl7JopgZN9CTcY0bnkfcokKmMlyWwSevqjEO9eVRXg6hHGweBdUXjOzLbe4S99zRbo
         gtNWDMZJJNfatXZ/tJbX1OW+n9nfpK0TX4Z8dgQaEGo3OjnfwwbXgmT35liDBpYngBNF
         /ZHQRXtLaNrKH7dbC8sTrGtT0+li7YPW+6CtHDdkZvhsHU87OjpJlTKteGLJ4qM6Ea9R
         dIqbxVmL8kN1ouhitirDiTh6qaDYbAGx48kIlLP9K4FmakIB5YB5bLPSb27PfSZcquLB
         8GYg==
X-Google-Smtp-Source: APXvYqy4FTIlx2aItsuQxIZvVQefOXR9rGZMq4Qqe1wQjbT5xfIvymu1nCUzfNvUSDQww2TREpvbig==
X-Received: by 2002:a17:90a:bf08:: with SMTP id c8mr23664541pjs.75.1561881448164;
        Sun, 30 Jun 2019 00:57:28 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id w10sm5989637pgs.32.2019.06.30.00.57.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 00:57:27 -0700 (PDT)
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
Subject: [PATCH 1/5] mm/vmalloc.c: Introduce a wrapper function of insert_vmap_area()
Date: Sun, 30 Jun 2019 15:56:46 +0800
Message-Id: <20190630075650.8516-2-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190630075650.8516-1-lpf.vector@gmail.com>
References: <20190630075650.8516-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The red-black tree whose root is vmap_area_root is called the
*BUSY* tree. Since function insert_vmap_area() is only used to
add vmap area to the *BUSY* tree, so add wrapper functions
insert_va_to_busy_tree for readability.

Besides, rename insert_vmap_area to __insert_vmap_area to indicate
that it should not be called directly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/vmalloc.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f76cca32a1c..0a46be76c63b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -641,7 +641,7 @@ augment_tree_propagate_from(struct vmap_area *va)
 }
 
 static void
-insert_vmap_area(struct vmap_area *va,
+__insert_vmap_area(struct vmap_area *va,
 	struct rb_root *root, struct list_head *head)
 {
 	struct rb_node **link;
@@ -651,6 +651,12 @@ insert_vmap_area(struct vmap_area *va,
 	link_va(va, root, parent, link, head);
 }
 
+static __always_inline void
+insert_va_to_busy_tree(struct vmap_area *va)
+{
+	__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+}
+
 static void
 insert_vmap_area_augment(struct vmap_area *va,
 	struct rb_node *from, struct rb_root *root,
@@ -1070,7 +1076,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	va->va_start = addr;
 	va->va_end = addr + size;
 	va->flags = 0;
-	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+	insert_va_to_busy_tree(va);
 
 	spin_unlock(&vmap_area_lock);
 
@@ -1871,7 +1877,7 @@ void __init vmalloc_init(void)
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
-		insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+		insert_va_to_busy_tree(va);
 	}
 
 	/*
@@ -3281,7 +3287,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		va->va_start = start;
 		va->va_end = start + size;
 
-		insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+		insert_va_to_busy_tree(va);
 	}
 
 	spin_unlock(&vmap_area_lock);
-- 
2.21.0


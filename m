Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84C04C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34F812087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LXwEOG+W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34F812087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9D536B0270; Tue, 16 Apr 2019 07:47:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C3A6B0271; Tue, 16 Apr 2019 07:47:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C14906B0272; Tue, 16 Apr 2019 07:47:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89F1F6B0270
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x5so13240614pll.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=c87hF3lw8XxA/PztWGmcpzGBUXAAi776at40dT0QuxTDJOCGRW74FUiH0iE8R38PpO
         iswDe6zxDQehYpXxJfASUJ+fcOUp5U9MIBzfL5ENtftnxBd06S4baTqQmqM6h9rGtYPs
         b9FdPYZHVXVABpBdla5asZ9XiKl721c+Yr6QaF1m1A4Zmc3EUln6k7zzUnli5ISyKCAZ
         5E/wUHHyuLiIh1Mz19W1cAbMsAM39P0wc0ScdTgEZkFVOavq/juYO5/D6oduPaqUZxgK
         tQ2eVBm8Tp71XDXgl9JagJsOnopYV17beMUu4CMmavhIuRzMM3mvHlHo9hr0KnZ6YOWh
         KoCw==
X-Gm-Message-State: APjAAAVn3rWh4b7AofVWR+wYQRaydstVIXhu15IHCl/W13JeQYPKQcus
	6kolvnXdoN8fQ4bVkmSuiEm0rHTjklXwlxl7vhncsa7JugbpPtw0A77LAmtVnODWJ+6DD/89sDo
	caZ7iSemr4UZlvsnAWs1PtTAjEkhPmg7MoEq3vlcgDeLOo21Tn2k+WPhkxJIfr5aUjQ==
X-Received: by 2002:a17:902:9a89:: with SMTP id w9mr82665096plp.126.1555415264236;
        Tue, 16 Apr 2019 04:47:44 -0700 (PDT)
X-Received: by 2002:a17:902:9a89:: with SMTP id w9mr82665048plp.126.1555415263513;
        Tue, 16 Apr 2019 04:47:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415263; cv=none;
        d=google.com; s=arc-20160816;
        b=XO0q/0DECa2BItRghDJe9dsG+Cot2F0CqGB/5XgboQ8rXBvJE+uG0Txi/OmMkSw3bc
         jWs6EdBx8ssz2QrM9Jz2zdttSi+IA87yjYoOY9kuKrP1w+coKA7UqvmteW52ZdJ+7bAK
         vEZR1QnJ6VbFsT2exn94oPOGCM3RYKSV1RVyUUJCNjNgDx3kkmno6Sb8NNAum9SnF48U
         9wRAQlipvuZzergwF6AF7l88qs/9jHe2q7q11Xb/6SuvSdwjUhp1jEqdgvAJcdtVDFMV
         I4Lk8CktsVEc3hxEy7aO7dTwL0zrzotieg4OYPjLA8yUO4e2Sv6pdD1XVeRC2X2clNzw
         N3vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=GmE6Sd3R9cbuJFJWumqfF25oXItouvvAloCrdH35uUvoERpJcGqhreizM/paIy/tNi
         g2uQJ/dU3LD6yt5g+mFcYepRNPkt/ZuAb449YxTNkLsFg3s/CPoR/0TfjqnXNBurllTh
         hCvwtvg+WASAonhtiW7oW7RtgViSiNIu5Fnh1SK6sNc6GXhK1bhIQdHSO78BOz+U+zXS
         cpL7p25r6Dj1EACLyTrxGi47g01Jrgk8itRZyd5ozW9ITX4t/3QSEq3FXS9zPq1mjVzB
         3i0RkSmCbbDonG6w89ezhOMU7TcHPY3l54KVKuwaZ5ShQ1k1d6PA0M9mvc/5ETwawXBY
         Ix5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LXwEOG+W;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g32sor57048821pgm.82.2019.04.16.04.47.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LXwEOG+W;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=LXwEOG+W0ZQnOV2lka03GCK9IgBNrr2lBHro8hNifiyxcZ1ikGgvj2ATkkyJCssND8
         uIPVeiMq3yAZqI2LRlD5+9ATQBkpSshzqQSOoBXRtlcWTYQLKVuuH4kaV4JTlXNkR+jC
         wC5P4kfnmC7ntOMn64m/bYNLTdyS4iMoIxEyoe9RYklbyAWpXNsUv/czOEu/u4O+CNOJ
         r+CoNYaio4w+bxXWIV46A5NDf57dX4MiBRpyE+Fjkp3V8JI4WHUYiIE1A4jZPA3tEpme
         8QQmC2+oUNqGbHI4n/hFz912t+1dDesjfB9zqyhAjR4tOEGZue5u9dsipu1pezIzmEMU
         KkhA==
X-Google-Smtp-Source: APXvYqye06grMbHjmTb1XwCWWLzi7D/Hr7gyojBySrV/ZCmbi+kTA1CovWh+pYieLteg38xYkWediQ==
X-Received: by 2002:a65:5089:: with SMTP id r9mr75893740pgp.14.1555415263156;
        Tue, 16 Apr 2019 04:47:43 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:42 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	riel@surriel.com,
	sfr@canb.auug.org.au,
	rppt@linux.vnet.ibm.com,
	peterz@infradead.org,
	linux@armlinux.org.uk,
	robin.murphy@arm.com,
	iamjoonsoo.kim@lge.com,
	treding@nvidia.com,
	keescook@chromium.org,
	m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de,
	hjc@rock-chips.com,
	heiko@sntech.de,
	airlied@linux.ie,
	oleksandr_andrushchenko@epam.com,
	joro@8bytes.org,
	pawel@osciak.com,
	kyungmin.park@samsung.com,
	mchehab@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org,
	linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org,
	iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [REBASE PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:48 +0530
Message-Id:
 <a953fe6b3056de1cc6eab654effdd4a22f125375.1552921225.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190416114948.mKONt03N3m5jkYtGKRTJh-2-PGWNbqw2W5JnhHUMy60@z>

Convert to use vm_map_pages() to map range of kernel memory
to user vma.

vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
not as a in-buffer offset by design and it always want to mmap a
whole buffer from its beginning.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Suggested-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 drivers/media/common/videobuf2/videobuf2-core.c    |  7 +++++++
 .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 ------
 drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++++++----------------
 3 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/drivers/media/common/videobuf2/videobuf2-core.c b/drivers/media/common/videobuf2/videobuf2-core.c
index 70e8c33..ca4577a 100644
--- a/drivers/media/common/videobuf2/videobuf2-core.c
+++ b/drivers/media/common/videobuf2/videobuf2-core.c
@@ -2175,6 +2175,13 @@ int vb2_mmap(struct vb2_queue *q, struct vm_area_struct *vma)
 		goto unlock;
 	}
 
+	/*
+	 * vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
+	 * not as a in-buffer offset. We always want to mmap a whole buffer
+	 * from its beginning.
+	 */
+	vma->vm_pgoff = 0;
+
 	ret = call_memop(vb, mmap, vb->planes[plane].mem_priv, vma);
 
 unlock:
diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
index aff0ab7..46245c5 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
@@ -186,12 +186,6 @@ static int vb2_dc_mmap(void *buf_priv, struct vm_area_struct *vma)
 		return -EINVAL;
 	}
 
-	/*
-	 * dma_mmap_* uses vm_pgoff as in-buffer offset, but we want to
-	 * map whole buffer
-	 */
-	vma->vm_pgoff = 0;
-
 	ret = dma_mmap_attrs(buf->dev, vma, buf->cookie,
 		buf->dma_addr, buf->size, buf->attrs);
 
diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
index 015e737..d6b8eca 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
@@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
 static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
 {
 	struct vb2_dma_sg_buf *buf = buf_priv;
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
-	int i = 0;
+	int err;
 
 	if (!buf) {
 		printk(KERN_ERR "No memory to map\n");
 		return -EINVAL;
 	}
 
-	do {
-		int ret;
-
-		ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
-		if (ret) {
-			printk(KERN_ERR "Remapping memory, error: %d\n", ret);
-			return ret;
-		}
-
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
-
+	err = vm_map_pages(vma, buf->pages, buf->num_pages);
+	if (err) {
+		printk(KERN_ERR "Remapping memory, error: %d\n", err);
+		return err;
+	}
 
 	/*
 	 * Use common vm_area operations to track buffer refcount.
-- 
1.9.1


Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9535C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:24:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5992820700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:24:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jwzR1+M3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5992820700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0092E6B0007; Mon, 18 Mar 2019 22:24:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA536B000A; Mon, 18 Mar 2019 22:24:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8D86B000C; Mon, 18 Mar 2019 22:24:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A73046B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:24:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b11so5737716pfo.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:24:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=IHFEj+2rXpmNnlzNdetI6HN374WaNniUVN1l0wOqoRaC5CfW09FdHwwd+dyK+4Qh0p
         M1qbngaRUJLYar/YEgZnENM7GrxKqN0tLlGKjEmTQcwezMZ7VcoofaS9AlumDdps1PG6
         QJZCVgpT7QrtKjDWBIuArFpEzWigoiu5GCBtQEELJU3sdsAhXbdtTfPraI0GcQDONxJ2
         5/ovC7DlZvacofBng/+yYsiX0S9LHlCaeQexEI4tnLutzYy0ZjQ8S9OMPGSKQsUXHG15
         hbbXVOeOivdY4NoSeC1OM3Ncbfl0WcKe85ByzDaM6kG/3OdpxiZYc0g8MVktkpws8LBb
         XS9g==
X-Gm-Message-State: APjAAAU8pHl8nZgxOgJsOzB84Rg08Nk+fzOvcl9L1FM6okeBOiBczjDA
	S7c4ZCrCylf14fI8LZhF+Un99sNXE+U39OgnFljzYgmKQyEXMdNsJe0fCEigHTxaiFbj22kvjix
	ocMAIbEBEdtY1dunYnmNPYp7OmKt5tmQ0N5HJhaXPg8/vwP/tapBLKiKZlhQUtDLodQ==
X-Received: by 2002:a63:fc62:: with SMTP id r34mr84930pgk.154.1552962285323;
        Mon, 18 Mar 2019 19:24:45 -0700 (PDT)
X-Received: by 2002:a63:fc62:: with SMTP id r34mr84854pgk.154.1552962283819;
        Mon, 18 Mar 2019 19:24:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962283; cv=none;
        d=google.com; s=arc-20160816;
        b=w6OUD6+uD5Oxc4C8HVw9xsM9GojZduYz3azXVrsObzewnRGr1hLEDdtkq8GurUGxhb
         iog8yew5nUY0I77hUrP2pBdF9zPH7vDPUyT4qoAB8XfjdWERX9JMUlWU9QFxIa+M6zlt
         LMD9WlcP4vCDf3fLKuwEuz2Lzk7flg6bNnphQA/R0mOPCgmbLSyR/pkfZ04l7C9HUAB9
         vgGCdWLzls09PKHDqAOt+IaQkn4tBi2SSUQNzGz6aAvfVD8bwibqkiBNNi+cxi4mO0Em
         fCVibexEv/LsaYKOI5WW87wB6vtN18R1k+eKwFQv1lFibM60H7Tx7ctLk1WXRtQQkI+X
         Mjlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=UKt6qPNKBOpuFy45gWP6PU2SqbWig0Jfye9/xbM4pWciUlxWyqZyX+xRUx4dF1ZT7d
         3mW1xKdDlOLqEWnDgeDZJ2ceMkYbDxq025CdB/5vcRqT93eZZi6zSpKl9aKOTQw9h3vS
         vGKzYHD+5wslmIeERo3Kg626DOREupAGBdMBMTHIaOly4DI979rTNRlqKDzaLUSM7f9l
         lHKDOpJoIY55ukMcY7ey7hhfFX+DmOoZ9KC36xjj12myZemD64EMbjY/1l6p/Kal6vse
         u8+7GHP4On6stpTTckvmlA26YR3CM3HWSUXDvsCJTtmkLD7YZhx/OXYzKO1EbBYgSz/R
         kzMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jwzR1+M3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31sor17523930pli.10.2019.03.18.19.24.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:24:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jwzR1+M3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=jwzR1+M3eF/sRpwxsvcpjrltIEFZIy10zkgdsp0+V18FdtMnCPXQkqPMMawEIrufNp
         18bJG1e9/OwLZhIb5iJMPIsrmwKJqo1crkkdqjtD6R2eRIFXVI66sm411hENaUMx8LNk
         N6il2ILt3PeGOwRzbIPSObPKkYWxPUYj1O9Uyl/p+KGYWxpshx9BztRDVhbLRCTKsmaA
         vW8v/9hl/wep1ehA16EntcBER+jkIhD/rHGGrnepaMVz2O7xuk0euKIyhiXHhOrD8XW1
         fUG0LeL/VbNCfs1m6XDXgjWGiruq1wYIMOTKxbEZwiVXbxRERdDgEgnkkFuB7EO8b4VF
         RePg==
X-Google-Smtp-Source: APXvYqxMdZ7HkxSFcd/qIJAARczAQkXpoQb865jAawnv3hwoKx/+hD/Cbw4bfxmUBGHIu3bO1uxxLQ==
X-Received: by 2002:a17:902:f20e:: with SMTP id gn14mr22842207plb.334.1552962283122;
        Mon, 18 Mar 2019 19:24:43 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id a7sm1159088pfc.45.2019.03.18.19.24.41
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:24:42 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:59:17 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, mchehab@kernel.org,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RESEND PATCH v4 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_map_pages()
Message-ID: <a953fe6b3056de1cc6eab654effdd4a22f125375.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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


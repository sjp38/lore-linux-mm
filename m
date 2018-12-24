Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CC2FC43612
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 243C521B69
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:23:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OUe2UBaI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 243C521B69
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9E168E0009; Mon, 24 Dec 2018 08:23:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A73B98E0001; Mon, 24 Dec 2018 08:23:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93C658E0009; Mon, 24 Dec 2018 08:23:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E15B8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:23:08 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so12441872pfs.20
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:23:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=7Lxrxd/hSsekQvS5TNwgf4HJhjrgrc3uztzkOk3jJZI=;
        b=dSPE2fx6LTi7nCH6/U0YftMlXEEIFV7POPfBX+YHZyaBdayjXJrHhH/9KhSwsx2yPX
         7BF1ZFJhdFFRnKzcO0Bg+o/73BzbW+wbWBo098s7FLYbFs3hpv9NCgK0eyDUH3DlJ6fX
         z9B+r+4QuEheGycfvnGtPsvaDje0d2I++Gvq+yLF8K2cDcnsmRZMwY/5O3CHUqjaMfgm
         E9FQJCW6RJQLhv3NgKIgEDShyl8gcsGYrYqEanwD9BIW48rC3WYJ2oy6rteYrbqcKa8y
         t6fSxw2PCaFLIGTf3wEjSIrmEYmPjXYtelhkqm22C58/wiJmZVlBdR9oNSduyy6Q2oW5
         /kDg==
X-Gm-Message-State: AA+aEWZzOF0S+snBlcopWD7148hIJpDWgw2lPzxPVKRR1uaFFkaQoeSZ
	z6j3oSHZTJ4hpqT14EJVSjdTNSV9BXGLJBMRyRWt3Bcj2jkT2UYztLhCo/21koY5NA3i0qhCCft
	yq2MvyT+jI0Da4U0idRQNKLvia8njh57w/l/ZU/XLihqgH7r7d3MFMx4R8GKYg6Y7IXfIbXZz7Y
	ukJmpttrwk1jzE/aox8d2jay/eiejAjNh+Y4nnwkhSUCLIJxW8vjoLw2c1i4dNb9J7MzIa++DCS
	gH96S8TyBxAinLlvOB5AL4uRhp356lgHSULxjvvArjp4tW/Yci3m2qCynjZncrE4K7GKOWK7GYF
	TR65nNYQGVAzx2USEHjqHt3BG/XYOHdXFC50r15DfVNcFVqCDQkMsPZaVHr+SsvNRhMLQziN3l8
	I
X-Received: by 2002:a62:31c1:: with SMTP id x184mr13505280pfx.204.1545657787869;
        Mon, 24 Dec 2018 05:23:07 -0800 (PST)
X-Received: by 2002:a62:31c1:: with SMTP id x184mr13505246pfx.204.1545657787205;
        Mon, 24 Dec 2018 05:23:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657787; cv=none;
        d=google.com; s=arc-20160816;
        b=mniGNGOpYmhWhWEW6+aUZEa7PdaJx96Js3n/mEVtdsonF5Em/07a7FRzjHAERcMEDL
         kLzgeoHViRHMn03jUjKYKWYkYY/QwA65e4xzJ8pa7tklKWTQnjSZCc5o804R1aiIB25e
         GwzW+tg6XcgooTfC++YyVYRg4LqLHSeqr6KxoWXXKuAhHO7YDZRy6rAwPEGRdzEFZ0Wn
         HEXn5Ii/btzpgVdLKOzHe4uL2vpx4aDTjY0GE8lr0SCP4J6Q74XIQR7qJbrt66Hvg0GR
         lzB29ycE5jGRUqQpl5MJh+sewqkf9XH9u+0SSSf/6I9OYVRrfVed++nh4J9tLtuJWx33
         /QpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=7Lxrxd/hSsekQvS5TNwgf4HJhjrgrc3uztzkOk3jJZI=;
        b=kaKIaCDQd5SRB2L0bysSDQi69Uirsx+gMxwK1PmJj+9yVMGSBNhN2D77IM5q4q+yBC
         0oW4sR9cqf0j1C9M4WVoSFQWygjvZqpB3HG+Y/XnDLS9RQ5NyP8E8BB4xSMFLrELMEok
         fgasagYbawGrPR2jL/Ueb3N0OeemPAROWgDZzCEl6HnnSgjZ81clYpllew82raGdJBIc
         Itr8tWgNgceh1EEoGKxf6jCk3Z8VtFuO9bvDPIb4F+rHxmOqmyiL77XIT/G/mJLMp86o
         4UyMMLBcYpwx2WySAxcVnRXLEE1dzXKkEdDFv0UVtfoOgLtLn0ppRNnewG+Nv7STrsOL
         i+OA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OUe2UBaI;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor48007192pll.68.2018.12.24.05.23.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:23:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OUe2UBaI;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=7Lxrxd/hSsekQvS5TNwgf4HJhjrgrc3uztzkOk3jJZI=;
        b=OUe2UBaIajVgiHJLICEiDaRmhg9kLK9hiO8qJEaN4rrxoH7k50qgnl6Wl+XySZ6A83
         K1F8jaG9lYHSpu0zG42YwEpn+3YVl83fnNiLu4sAHKartC0Io7zN3jOBUYys/J2s1DAZ
         b0PemUtLvUPsZJ5WxS7a2Km1y+FbdYwd8Vqu1nOnq7zc0AYFm2cvML/bPUIVJE6z7kYI
         AarkWAB0WEA5VKCBss7dFq5ZPZq2mCmrnovbMMEXL5zRYsntVdEdUqvwab2ix4w5+GaZ
         lufgucxKqEtCZUxR5YLGIYS/gi5CtHr7q3PFICiRvdOSX2NGp352oE4H40jHM582Ec4m
         GYGg==
X-Google-Smtp-Source: ALg8bN5kc/0nicwedA6pXaMV79OMWDwnVCptGPVVG8nZTTXxzJdQVTtTwoK88u8a5GB5BsbXczYDpg==
X-Received: by 2002:a17:902:4401:: with SMTP id k1mr13003110pld.307.1545657786489;
        Mon, 24 Dec 2018 05:23:06 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id x3sm101409071pgt.45.2018.12.24.05.23.05
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:23:05 -0800 (PST)
Date: Mon, 24 Dec 2018 18:56:58 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, mchehab@kernel.org,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v5 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range
Message-ID: <20181224132658.GA22166@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132658.Ej3lTbjw-qwie0_TevQuVDDVZ44xK6I90-lfWKPzins@z>

Convert to use vm_insert_range to map range of kernel memory
to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
---
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
index 015e737..898adef 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
@@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
 static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
 {
 	struct vb2_dma_sg_buf *buf = buf_priv;
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
-	int i = 0;
+	unsigned long page_count = vma_pages(vma);
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
+	err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
+	if (err) {
+		printk(KERN_ERR "Remapping memory, error: %d\n", err);
+		return err;
+	}
 
 	/*
 	 * Use common vm_area operations to track buffer refcount.
-- 
1.9.1


Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 363D8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E763B222C9
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:43:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="inn83Ew3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E763B222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87D988E0006; Thu, 14 Feb 2019 21:43:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B738E0001; Thu, 14 Feb 2019 21:43:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CCEF8E0006; Thu, 14 Feb 2019 21:43:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 243668E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:43:27 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 75so6406853pfq.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:43:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=Vik7NIYt6jSNZrAiunSY4X4yXrT9RGM2kBQHeeL9FqgClYHazSAfC/810zMNShc1O+
         As9xi3Z+sKRQ39GHI6Qn5txAG5sknY1Tpa/fGXxg8bpaJR8AGyhmXZ6RPHdV4Bpz8zbd
         2AEwPVWS2hF8Lc/vOefOyTrRZwo6+u52PBxE87LG8d7N2IiF1OxGzSJCerqPKwcX+EcG
         ut4ZSAbZFLLWbKRedcb3HMya8bMAUA5W2e95JbJzQ0QOR4887xMtVOvDZ8mcfOy5OyFv
         QhAnSXgx5HiWqiTrRYkG4ogtXNYLp7UXisHGlw5GP8Bu56eVdExQt4PWlJZhNSsnHEUS
         HkUw==
X-Gm-Message-State: AHQUAuYDE630y1eT3Ifx97fJGcDMHe4g7ZBGDK1ZjdfB0kwTG1bK8f7y
	4fOYG1ZEBv3gOc/qTh/QoS18+5pkntfKvTZcMvKci7p0H1gdZ9MBg8kd3qcDB6AisjnC9sMqcAI
	rL043Tul7OBt6dirpnn1W+Nx9XeEn+vkqkg21OGeEf2jt50XvYJ25yvfAKCGOA6/kuarIPmLkvk
	IQfUPC8ErBj7xPkuE+QEQ4azOPJu9NvwHAOY5APRo64I8iU/lWwwx+zC3UXRadazidOme7+3uJK
	p9X1fuVOnOUM+nWL9LFqjrMxgDlm1iIf/87wyPDG7QouKG6PJb+3QMjzDXrX1iozn/Z92feDRMP
	UnaaJAIJqtXS4db0ig8eWk0sqit+LqWYGxzF0Wk7sUChH2DX+/ADT14JXhbW3hjVPjPVGWPBcUM
	1
X-Received: by 2002:a63:2d5:: with SMTP id 204mr3054529pgc.407.1550198606768;
        Thu, 14 Feb 2019 18:43:26 -0800 (PST)
X-Received: by 2002:a63:2d5:: with SMTP id 204mr3054486pgc.407.1550198605991;
        Thu, 14 Feb 2019 18:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198605; cv=none;
        d=google.com; s=arc-20160816;
        b=jRuR1dWvU+vbM8wddNKzvVZLBUFtCE6MZZmR9uB2lE8X7h3HiAdWwqthl4qXhl2aG7
         vwsA5qN8lx1HQFQRJCkbgwA1w1FIZ+CnSx2SPxGkv2KJ/G4JeRf4ouf0mo1dw4t9l4LF
         dM30ddkcvGQT49M7IEheKzKWW9Xs9151hT2kmcWwD5JL6n2cw1dN8jr18iBovK/GPQ5J
         f+rMzM9O5luK8fosC0W6uAFmFq+9i2hv+sh2Q7Djxj0Vjf/Xpj4ZjLBmqK9fdgiP8dVr
         ynryVf+zoutBVgKevW8Osz/oPGJNO31yD2xObgp5nnChwRj9aJGj1P/5Bob3dKSepWrn
         5Q2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=IAgmqYNhNQir/ESihgOZkUK2ZsK7lZ6QvStYrbrEB55ULMd+9sYEnWSIVeFt7N9CgQ
         21jMLXj6bJHTMOBUZspzsKIpw7iVh9b1b7go7km8WWz0TZIhe5ycBgFkzu7ukGGJQCaZ
         gNkSgooKdFYw2Cgt1YHoA3yx04Jr2c+cyNYPgX2Yz0EPDU4ScAc5nlm9X+Yeh98xtlMJ
         6cUzrtJq4NUrtEFDLC92GsQtuT2xfFPEEnKf82VCOa6m0Bkyqkosvw2842aYSCbeXJs8
         21QAKWD7DwofbfsRIILsKZVkK/r+u/gNFUdRIry7evEEDZJQ09ViGQw0KbCpvL5d9p8g
         8lzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=inn83Ew3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q3sor6590617pgi.58.2019.02.14.18.43.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:43:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=inn83Ew3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=36ygGGspzW8ypHYiojY4a19UR4qM+LFcK/AqwiiUnW8=;
        b=inn83Ew357K/ih8pfbluD0tHChrNBeWgVepxNoqLsPfTGsSVcd+Y2TvNyaOt6tsH+E
         l50EUJtl8WJgmunL6lScD8TdLHN40Al7FiBSXz8sPTFqYjA1D9Y538OponFb/96GzpPK
         c7Gs+mH17TuI2e4p6V0hcG4Do42SWlWbQApZfFxh68EAjYcMIWUuUYrw86EOJbzKhDiD
         F9cHRzu5G/0kaQnWGWV+JeffZh9moTJCTuaKNTxwhDR9Q9myrlC+HXeayONpB5vLZOo9
         qKY92nsunQvlYAczN6fc4SxQaNmIXCkZXCJd5cqy9NompO6I5cSTc/B1zSJVmYRUGkNJ
         MolA==
X-Google-Smtp-Source: AHgI3IY4Y9LsUJAtQBeI8TTrDehjCuwGc2OKrBuTZ9TvWhq4etnfiX7gHURQ6oqPUVyDoepRwe1zcQ==
X-Received: by 2002:a65:6249:: with SMTP id q9mr3013034pgv.229.1550198605218;
        Thu, 14 Feb 2019 18:43:25 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id g10sm4582058pgo.64.2019.02.14.18.43.23
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:43:24 -0800 (PST)
Date: Fri, 15 Feb 2019 08:17:45 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, mchehab@kernel.org,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v4 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_map_pages()
Message-ID: <20190215024745.GA26461@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
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


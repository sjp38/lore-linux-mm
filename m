Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F2BAC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3476D21880
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:42:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C8WU+shx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3476D21880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 091416B027C; Thu,  8 Aug 2019 11:42:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0411F6B027D; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9A3F6B027F; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B19846B027C
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:42:56 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o6so55681696plk.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:42:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qoYaUeTX6kw3ANFQpuUtmmKlzLoKmX03PXm3Ah6Uf/k=;
        b=amguUjU/vosMzpVMqKIIu3R2qsQxCkuQOrk+GffMdADgtEc+MzYy6wqLRu2nGB0Kkw
         qi1jIulKfvM8gGRMWM+mmxMRBHuS33QC9LQNtbQfphVFJXBN9KWEtb0eSBsIwg07Pzxe
         aRekDByzWXyf1Aws+4dzY0yP7wIFHTGbU343PWNUyL++FhyEbYn3s1yvKqqChh9fZxN7
         k/uWTF6g9fnlVjflBhxOqf/6yxjoiAyOCShVGW/vIVY3eldCA6SWZspydTWodlesDBcc
         /ptLCEkN/4t6zjbeq/9sk2dM1Sy0eQ5AxQVRRYPQLfQpb1p9OfyWu0wb5OXxFLOIAioB
         QWbg==
X-Gm-Message-State: APjAAAWEq4rk3uKIRrwEIm714R2tP5pmoVNDjnlW40bP+BYrdmDjYDwj
	ObHdVUHv4JV9OOn3j5YXIFMyb4sjiZlr1cLInhcpvVAOAnIZ6NI8XR0YT8ebgv6NSHEYx241jF3
	GeHCwxklb5wAPiLD424Er4KRGNK4NzRrmkFSNkyynvMfy7yErrHTEy5+LK+tZCSs=
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr13889045plp.95.1565278976381;
        Thu, 08 Aug 2019 08:42:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNpA6EE3ixD7MXpu1UsCgDD9gTih72CyLMpoBmhT1W7OwjzBeizvAnTRN3I+Wx75+Mz7uZ
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr13888994plp.95.1565278975418;
        Thu, 08 Aug 2019 08:42:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278975; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOLJmVIlUQX3NRqKbyzm/HseKZ8f5HhniEjZlfP7fqwXG3iHohcozlOi09qbdX2Uf7
         2QsFcFZqEXOSXifmx1Fw4AAmQ7inHz899/t/vO0PVsrwMtbEoLWT3IjDcrR0xZUPCDut
         +QvwSX9OrA00+gR97RRtM1Gr3VlE04Y6E2PaotfqrfkkOMkuzFJ6dRvbPttHHMMjhziG
         r8poHdV5YiQ6dAGOozl8+CFc1yvrI5mcB0ryezinBiXZBpM/EB66XNx7RoTB6fVC20bU
         m551Phdp+WCAaCp9gbjZaOeVx4fNzDcFixdTMpaKnxTIKzW1QLQkvMA3AM9t8jxhJPGc
         SNyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qoYaUeTX6kw3ANFQpuUtmmKlzLoKmX03PXm3Ah6Uf/k=;
        b=f2+i3fY1UosMK1v5s3zXsdApfF+SZGGIuCuP4fw6EWIWm37DV04TFR7OLeDDZgNafn
         kmmH11zH5h6/2Eg+wtgq023ZSdmC+Opknso+0L4qXXDk+6p745JXOHjH+O+LchVXFSaH
         6b5uJ57LHfmHrP/Y8Elr8xhdDMdIf8ejTJzCzEhDdo88eFAsW6oNhzFBI9G0XhBa+ssO
         tWs5ozihQdZ208R9cTXAZcZWv8yCYiQNsAba1ZVJ1Qr58tXE6W27rwQnvA7r0a1L6wbL
         YoS/OP/j9lDEL+VfjdlDfnGfZiSeCOfe0m5J+FeLIvJY/ZtEPprBFSRNcVtvNNyNcTlE
         kIwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C8WU+shx;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a89si51878566pla.60.2019.08.08.08.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:42:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C8WU+shx;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=qoYaUeTX6kw3ANFQpuUtmmKlzLoKmX03PXm3Ah6Uf/k=; b=C8WU+shxCqtJgFK4W6BVr72MB4
	iqFJN4NcAE8VQCLTnWdSOTVjPgbU+yGpNkh3/1SYrjyHGc/dOcepyoxjMsjFakuzNs7fR3+c8ZgZ7
	s+P/mhbtZPHz1buQd4VQxo9vp4So9TcFHvNecibB59+tmPvBkrmhP7o+merNfhTzJy0xFUS0Box6t
	SiUSG909IQyiE9Z3NBipjp1FH82pFfvw4EJBFxqxwBjNq0rYllcA9o+dmcX3AOfMFla7sCFN03x0u
	KGv0FNiNyq3iTXP6OhQRnVk7JRNCaAn5QVUOjR96C6/nXuFik+y/b+rmpg62AgATdN3XakZhmJOqs
	LFoIdkVA==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkZ0-0008VE-O8; Thu, 08 Aug 2019 15:42:51 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] pagewalk: use lockdep_assert_held for locking validation
Date: Thu,  8 Aug 2019 18:42:40 +0300
Message-Id: <20190808154240.9384-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808154240.9384-1-hch@lst.de>
References: <20190808154240.9384-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use lockdep to check for held locks instead of using home grown
asserts.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/pagewalk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 28510fc0dde1..9ec1885ceed7 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -319,7 +319,7 @@ int walk_page_range(struct mm_struct *mm, unsigned long start,
 	if (!walk.mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
+	lockdep_assert_held(&walk.mm->mmap_sem);
 
 	vma = find_vma(walk.mm, start);
 	do {
@@ -369,7 +369,7 @@ int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *ops,
 	if (!walk.mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
+	lockdep_assert_held(&walk.mm->mmap_sem);
 
 	err = walk_page_test(vma->vm_start, vma->vm_end, &walk);
 	if (err > 0)
-- 
2.20.1


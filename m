Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B63DC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52C7920B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SRjdRB90"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52C7920B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50F2E6B000A; Mon,  1 Jul 2019 02:20:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49D608E0003; Mon,  1 Jul 2019 02:20:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DB2B8E0002; Mon,  1 Jul 2019 02:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id DAA236B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:37 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id a21so7026762pgh.11
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aDDV0kJ/bs5He1sJYNTcx8QRyDKaqv7PRbW2xYMan0w=;
        b=YwUBerc6pVckvp4m7MYL3qhZWVCDW2xXeQmw1Y8S7cuoyoFv0GiulQJsbRHa4+8HCX
         XMwQ7NB2/LmcD9lk8rKpHccmKM9Z6/0us4dgeXpbTl9GdYi7YJeSsfsyTDlzbVx39WJi
         aL5ZRKG34+O2prjHCmeFjdtwlwZsdmGWYZr+KB3/3t97vfrl1AB1zk+9SwxTYB9nJReK
         5pGYCfm80Zt+To7z4Nf1BRadPQBDtMxbNIEnvyjH7kCQEGjpU87OIhrIp5Snkr8nSbAa
         zQ2NTQoMhEjW8rG3J/0yycbkOCYSeoyLYM2tpAR0ntuf9OQuymVsWuGvo15acZV+UThJ
         osKw==
X-Gm-Message-State: APjAAAWsrYh4dE2NJE+GRZt4C+/nNd6y8gZ6fi8588hZzxEcIJr3CuAp
	k2R6j1FAehi0iCxm6LNGjblrZxPQMplZLw2yq1yccE+1DadxDgbv0SS7Il/VRtQpMJYAB8gMYi2
	95bzp84xLs99CUR1Qv51hn7NQEwRYqHzJxqmUgbB+syN9gxzeUvnwWBDF9BnBZHs=
X-Received: by 2002:a65:6694:: with SMTP id b20mr22425419pgw.155.1561962037526;
        Sun, 30 Jun 2019 23:20:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8y+jm3hl8m061auXljv4XjBfV/zYSeVTqlHUEr0iE2zp8NoNFdAtDG536W9XTtRe8NImL
X-Received: by 2002:a65:6694:: with SMTP id b20mr22425349pgw.155.1561962036599;
        Sun, 30 Jun 2019 23:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962036; cv=none;
        d=google.com; s=arc-20160816;
        b=e57f/dn3K7tJHeQFT4B90ga+RefryuMs08EDRypBubGDI7EjxQFVT2BOyDWeCpqLGI
         FzKRCvMScTGZN3RWknjiei4MMr3M9i9H84MDDN5lHD5RpHwZvCc8yahuEZZi/7c2exp8
         A6RUB2ZxWq12yoStMmk4LJA7CkdLDUOUc/glUK9oaQtREvvoX7qIU9w13nVFnMP8pJZw
         tCOLL0nVM9hR3uaUKawyn2AHOUVI1ENxBh40Dzi6BMSKOgmZ7FPf+zp6SI0918q5qhFI
         IEns5Ucx4FRdqPoluP/xoGUKYwdI3BXelHPhVHEbA0YOttvR/4J5rzA6e9MjrzKNM+KW
         AP+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aDDV0kJ/bs5He1sJYNTcx8QRyDKaqv7PRbW2xYMan0w=;
        b=RVHYvLzs5DyHJR0oPncEXr+egay7CGSN2fJ8x+HvfY6fmDPiaedx6Y5ozy07187VH/
         brxVK5yhY71/Ug9+59upWH0/7/JMO4AW0Rioi6euMYfymIIJZV82WPdWfww/viJgmImY
         QJOps4JH10+KjL6B9lxo3AsDNDMe+suE/vWowfhRINeFbQQLG6UJTR/xqu79rbG+3N+D
         zA3ab4StekbLAMe1h+MbtP8HMH191AbWwp884+OsCPD2JWcyuTw9/ZhmF5wdhtl94K2y
         jFW2h2o8uYG0+LjNQxPRU3KFO7P8PvOaQU9IxRNj2rrltNIB3hjA2edWbNyu0KSBzNtZ
         poOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SRjdRB90;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l70si5115919pgd.363.2019.06.30.23.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=SRjdRB90;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aDDV0kJ/bs5He1sJYNTcx8QRyDKaqv7PRbW2xYMan0w=; b=SRjdRB90aDp9ri+nwpQyyHN9q
	qGQh2uFv5+oBVnpCH4SJ+S82Wpl/5WlkHeVnbWe5AlpG9jmwibSgKOUPVlmKBymW6MzbzMs+Z5o5x
	Ggnd73UXr0J0EaH1JLkQ+tGELOwpt6iVaxq/8Lv9lorXyp9nYihVahCxuZEkCLErZAFZV/QTwiXbj
	oiqBjQ3hmd4hDDsYPsDc5xc2RtHEVg21y2T/8EgBWohFixCBg5aFXa4NXJZnpcyUlA/vxFRjuIkQg
	kNIQKzf0Emx+NwpXszIeVaqahmKQdjRNxfXxrmrM0Gmy6pasBag0nyerbXo0boyU6/Q3xNOwrjEQY
	5fLWM2pmQ==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpg1-0002tx-JM; Mon, 01 Jul 2019 06:20:33 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: [PATCH 05/22] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for non-blocking
Date: Mon,  1 Jul 2019 08:20:03 +0200
Message-Id: <20190701062020.19239-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Kuehling, Felix" <Felix.Kuehling@amd.com>

Don't set this flag by default in hmm_vma_do_fault. It is set
conditionally just a few lines below. Setting it unconditionally can lead
to handle_mm_fault doing a non-blocking fault, returning -EBUSY and
unlocking mmap_sem unexpectedly.

Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index dce4e70e648a..826816ab2377 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -328,7 +328,7 @@ struct hmm_vma_walk {
 static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 			    bool write_fault, uint64_t *pfn)
 {
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
+	unsigned int flags = FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-- 
2.20.1


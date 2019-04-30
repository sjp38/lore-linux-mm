Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44862C46470
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA85021707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="G3VBJNj1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA85021707
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C893F6B026F; Tue, 30 Apr 2019 09:26:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5F136B0270; Tue, 30 Apr 2019 09:26:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB72C6B0271; Tue, 30 Apr 2019 09:26:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6686B6B026F
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:26:02 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id j5so5423719oif.14
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:26:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=xNbRPHb0QaxGlTA7s33PjaJCVzzZC2iohEMIfDhjOnw=;
        b=IJNLUDRLMbw+MhelDX94rRf7XxentmBfB93rpqveAwke9gi9G2x2OcHMrOhu9HPbfD
         eY/R3YwaZxIaI/crwGKyTebhLuCC6XbzRVLUi1JsUQRr6pjPmY9nD3C87+vVwbV6uz1F
         08fbvN1w3KbJZX78J5gk4ivFqq7b9THhPJgHXP0mc7stJkKfnf/1WpqlI9T0Imtojqds
         n3oCR0BwWMbBseZh2mD/P3cSOzIOA7FoY0M48ps+QYzsb52ghphfx+vSug660lq32Rkg
         dPhdMyCHyAFIfd++Ha7z7Kr1a6JNXWDQ0rSjB1rZwzwe9F5cUIgp+KsiGxhzGqtV+Rj8
         JUVw==
X-Gm-Message-State: APjAAAV6ATyTfhs5AqmHKgDBUXyvfIz9zRkFjkZBZWLkTZrrJZCd7vVh
	bkmhszXXwzogVO62kNhHXB6eb/OGxAP604f3SPc8wh/aP6R7YpNGAFTEQDSq9bxnYrBKRMpfU0o
	poXFg+zERIeTbl7roDC131a9X+hCeFxnGk311coAfo04+KMtNBAyelq3yoJ6dPxyQDA==
X-Received: by 2002:aca:f086:: with SMTP id o128mr2834995oih.101.1556630762065;
        Tue, 30 Apr 2019 06:26:02 -0700 (PDT)
X-Received: by 2002:aca:f086:: with SMTP id o128mr2834951oih.101.1556630761270;
        Tue, 30 Apr 2019 06:26:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630761; cv=none;
        d=google.com; s=arc-20160816;
        b=XDa6cbJOt2b4QAEcY7laoxKUVTBNwx51sIf7/BHgPQIXZuiMRbcVt08tzgAJuC5g+D
         F2EmuuNxGS+i+QyOxDnu/+JRnbWypvXEIV8znQfRinnEycPgjAKqLRBLICQZmTyScX0k
         CKOFEQTp65/S/rXRvXvAqfQHG7Tlk9UzEUMk02upb0zUckaip7Uxzbz652W/oX8NwUyu
         6vjmc755zkq/6hm+2n40gVsU3TH/Q5vNGsLk12z2HYvIWf5kwbfyuDrQfjr6cIHxB8zA
         X9mGtSHCzX0ieMxfKz145Q/XPBJgn7MOJWQFOwSydQIhAlh2sMz/mkM083vma5sz6n8S
         7QXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=xNbRPHb0QaxGlTA7s33PjaJCVzzZC2iohEMIfDhjOnw=;
        b=csgpchRqirHKxGDpbo8i9kXVUtu0SvVE35ZkXxmGFywWJVdsB3nY9sqjvKLzOt9U36
         NSmtVQWplXJfNX3X7qzWismtgZgXykBD7x8Gz2/tn3soHZBlYTggj5Wv6zT9A8hPHB8I
         JgZxi0fPkppWQ4Q4yZs+jiwXaiXDFw1FAlKbhEe3FAZXaB5g6soTV+qgf/jGrAjr5fkO
         HWOt9zLN7fET7B12yj8G9AiPoNuUeJpXD+qOKiSBBeN5iqnGS3plC79Umy9T4WzbUfKH
         RE+Ot03tVRTWuNRV5N9ATKupxxFGXLU7YY/psS4+jQbkHl05k/rG+5hjwtu+en1GlUih
         wOCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=G3VBJNj1;
       spf=pass (google.com: domain of 36ezixaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36EzIXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i186sor10665415oih.32.2019.04.30.06.26.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:26:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of 36ezixaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=G3VBJNj1;
       spf=pass (google.com: domain of 36ezixaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=36EzIXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=xNbRPHb0QaxGlTA7s33PjaJCVzzZC2iohEMIfDhjOnw=;
        b=G3VBJNj1Efd82TURXBcG2ETfYyZa4nNQbw5XcSPgrFNgGTDcrjKi2K3Iqxh9GCJaVT
         q4ybexiR1zpb+d5J4+ktYX//GzTjjx7hvSHawuAMH2628bR7wRgw71HvGhNfTflHW/zs
         Atp0zpFkZrhjqB1YK2fIhTRq2d162F4gSLgDXmj1SWW0QKaRzutUGTNf9j2DzCy8DQXs
         6qis1IjWlpcydKHrLlqfebzxPQ65WrUm0DNZpeC309u8+WueXbRuj/bbSEKVwswOSRBh
         9Q1k1UxCvXqArWAzlxVP1yBw+FzmFzBJan3FvrRViSuycjCJ8f4ZVoJHTVS0bktu9b7r
         znhA==
X-Google-Smtp-Source: APXvYqzqz0hM8566mMMykEcEDE15qguKaKv3Gnp85A2T0WJw46tHTZ3v4v+uUTcgMqiUvlhCC6+9Qaw/183DYgvX
X-Received: by 2002:a05:6808:4ca:: with SMTP id a10mr3005375oie.35.1556630760913;
 Tue, 30 Apr 2019 06:26:00 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:10 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <66262e91c1768bf61e78456608a8a5190ea4e1d8.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 14/17] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

videobuf_dma_contig_user_get() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e1bf50df4c70..8a1ddd146b17 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {
+	unsigned long untagged_baddr = untagged_addr(vb->baddr);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long prev_pfn, this_pfn;
@@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned int offset;
 	int ret;
 
-	offset = vb->baddr & ~PAGE_MASK;
+	offset = untagged_baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
 	down_read(&mm->mmap_sem);
 
-	vma = find_vma(mm, vb->baddr);
+	vma = find_vma(mm, untagged_baddr);
 	if (!vma)
 		goto out_up;
 
-	if ((vb->baddr + mem->size) > vma->vm_end)
+	if ((untagged_baddr + mem->size) > vma->vm_end)
 		goto out_up;
 
 	pages_done = 0;
 	prev_pfn = 0; /* kill warning */
-	user_address = vb->baddr;
+	user_address = untagged_baddr;
 
 	while (pages_done < (mem->size >> PAGE_SHIFT)) {
 		ret = follow_pfn(vma, user_address, &this_pfn);
-- 
2.21.0.593.g511ec345e18-goog


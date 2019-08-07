Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D1A0C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8AB12173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JTummjFB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AB12173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 304ED6B000D; Tue,  6 Aug 2019 21:33:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17CB36B000E; Tue,  6 Aug 2019 21:33:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E98226B0010; Tue,  6 Aug 2019 21:33:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE8486B000D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:55 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so57098787pfo.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=liEP096saANMUUYUvdPzveQNn33mxbcLrTtHO/r+DukfvnZOxLk7sLoBK2D02cmoaW
         fB3CupUU+0NJ1Z+lA1Ejt5DymK/0WcYeeLBHuY2iOajsk0ruFrYEVacHnzBXJtKnEtwF
         NcYulXOc+VVcUPPBxu+UBJI3AAIPCZcFL3lAz4BV1yB+hTFVpbV76TUVkHWfMf9Dk48W
         Mcfg+GZ8/9fkZY59L5dJTrb/19A8+qtNK4MJpnammmnrtCPfecG9L/sAdORBBO7EvEHj
         DUJxprUy0rcHT95lk9Bn5k/r5lXoL8ZQCp77nx0cYBHp8sQMtd5W+DwRVjilAN6CVSGU
         z4tg==
X-Gm-Message-State: APjAAAVnPvkQurZW/7yhdFBa+mfPJoxo+Ghh6j0bPMqnf5mEmbZ2fXHy
	AtRfgN1vRoSuCp1AHJX2eRart2VRu3uMIHRGC+SkFMTreO8ybIdJmcoXSGd9Dq5hKRqzLGY8tEJ
	MMJ62a2Pt4/MEI4zdGLNBMY79tEYmYuGDMvK7sK2KpxJQ5q2ezXP3azglhUijKa7xAw==
X-Received: by 2002:a63:211c:: with SMTP id h28mr5501664pgh.438.1565141635255;
        Tue, 06 Aug 2019 18:33:55 -0700 (PDT)
X-Received: by 2002:a63:211c:: with SMTP id h28mr5501625pgh.438.1565141634442;
        Tue, 06 Aug 2019 18:33:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141634; cv=none;
        d=google.com; s=arc-20160816;
        b=XPLlCuc+oyXuqrfNYSf29oF0YX1MSitRlg0wC2Bb0HzHtHDEys5R3uswmFfDSA+V2z
         QCfsHnGaZs2bc3cxLvHSsRISZV2IAPIBe4fdjvJolah/dz/6wN12DQHYWORjySaFv/Zj
         DluqDc9vRMwEUccl4uRU94tF1hVa3Xtrdtu1m51/MQe/C51kHV/Vas+3zl/hjbdGw71f
         YRBMvqupPE6LXhtt2GJ07S6oMR+J9Cv92Zy854FcYPbKpPFwd6Q/vI4ie9qjmt2lzh6/
         itZFx2/7VfSQgjrHdMvUihJ60S/bQ6MRY0S3mXiTehcAxvlep79lrtzho+EBFS3cu3TG
         UcbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=BKFVcfpxEoAo7i9WjQ7UMsZDKfGlzWWicfzO7p16Qu8IXrJyj8yHpwdHm5kCbnsBQ7
         nyr1pWMjIUbnRSeePgg0w0WZ+wFxr5MDd0JxABglq0PilXIT2bxwSJc5z46Fs8SOd3v6
         fF4jpOpLAiNI56QSFG9tdtQpRQ8YzpxuLzXmEMCOwIZil1Se1lrt7TKHFpI8A8i1Gg7W
         j27HX3qoCbBml4ksGiUv7d05By5MmUWAtrcN8jQNXRxirMZTxy0rokJI60yRE07utFLh
         7GbhptFuzPxx0sxBS1Pt/yywpROOhxV5CdaONXZIN6LT/G5D0pjCZQmuez6yBzyU8Ili
         jFFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JTummjFB;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor105951334plr.72.2019.08.06.18.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JTummjFB;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=o0zfkIFt+6JH2qCeaVwPptBUW8DYTI9b55PprZaXkM8=;
        b=JTummjFBnv/C+O19cpD5WnNljDRNFTGhD+ZhdI4mJ0KthoLkEPnz/XxGJof7+/5P4n
         NHHwYbiLQNiC7TcqgsQ/ovMZm7D6aJYiNSrmCXoGWlQrghDLY3t836yj0IsY0+4YC7xI
         eQkZg6NO1m+ejC4ev3+3CL0uIAy7xorACp1mEOdDq8740Rm+KlATM1Sc7ZQ3MeqeRt4O
         7cYGE39/ttj6uSJue/JhAE5of4ahDgxaps2hbC4CGOdXTBLt0I5b2m9zlW7Y/wUMcwRM
         CKumpnCTxX+R2m3tIGG+Kc4MncXcm2KfRB66iumh4vvbbc51XwcZQfEKOAaVsSQiCWNy
         JHKw==
X-Google-Smtp-Source: APXvYqyrNSY9uu6qIRB6tCHKaxkbamRoI3EYz9mMxQODHddaqnRle1Efzwc3BX/1sry+PskKxKx5MA==
X-Received: by 2002:a17:902:4401:: with SMTP id k1mr5853733pld.193.1565141634169;
        Tue, 06 Aug 2019 18:33:54 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:53 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Joerg Roedel <joro@8bytes.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H . Peter Anvin" <hpa@zytor.com>
Subject: [PATCH v3 06/41] x86/kvm: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:05 -0700
Message-Id: <20190807013340.9706-7-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Joerg Roedel <joro@8bytes.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: x86@kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 arch/x86/kvm/svm.c  | 4 ++--
 virt/kvm/kvm_main.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 7eafc6907861..ff93c923ed36 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -1827,7 +1827,7 @@ static struct page **sev_pin_memory(struct kvm *kvm, unsigned long uaddr,
 
 err:
 	if (npinned > 0)
-		release_pages(pages, npinned);
+		put_user_pages(pages, npinned);
 
 	kvfree(pages);
 	return NULL;
@@ -1838,7 +1838,7 @@ static void sev_unpin_memory(struct kvm *kvm, struct page **pages,
 {
 	struct kvm_sev_info *sev = &to_kvm_svm(kvm)->sev_info;
 
-	release_pages(pages, npages);
+	put_user_pages(pages, npages);
 	kvfree(pages);
 	sev->pages_locked -= npages;
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 887f3b0c2b60..4b6a596ea8e9 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1499,7 +1499,7 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 
 		if (__get_user_pages_fast(addr, 1, 1, &wpage) == 1) {
 			*writable = true;
-			put_page(page);
+			put_user_page(page);
 			page = wpage;
 		}
 	}
@@ -1831,7 +1831,7 @@ EXPORT_SYMBOL_GPL(kvm_release_page_clean);
 void kvm_release_pfn_clean(kvm_pfn_t pfn)
 {
 	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn))
-		put_page(pfn_to_page(pfn));
+		put_user_page(pfn_to_page(pfn));
 }
 EXPORT_SYMBOL_GPL(kvm_release_pfn_clean);
 
-- 
2.22.0


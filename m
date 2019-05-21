Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A68ECC18E7C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66D872183F
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66D872183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50AFE6B0006; Tue, 21 May 2019 16:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 473C56B0003; Tue, 21 May 2019 16:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15DBF6B0003; Tue, 21 May 2019 16:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A96866B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:53:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so98985pfg.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dBwMVE9KbttCg2XLI675VZQsOGlnJ1c9VoXvCDMDOLs=;
        b=OHABhJwLFlGrup1GjG4jzphCJtwJw0iZHk6OAj4mZaq/HI6T+zjA493mVKqmGrOqmj
         hjWwl1JjUJDvffbEjlRLhDo3EbWla9QSyo6YdyeWj9AvVG1xZWMKK8i2L8Y+L8JpQtrg
         699sMjg9dNwr6ESA2DpKes6tsS6yNj+1gAu2sWNqekGZYdu0L5XEh1qN3T737D7JI2Oy
         31cV+p8HKvghfGIJbBa/d77tO3ukBuvDB9d8iSDTdU6C82oOsaOixRPu+XHP+XnsCK8P
         emRCXAULJDsuR7vftyQMUVTY8z8bdHjgHut2vQe13g6vblRwZWZIbbWHXCYW+k3pKH3h
         EuwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVi8oqeouYDdindhJ0lxKWCX2+FC9Zx7mPXhha8WDIFkpAWmlzU
	AF1kMmctazkYnfzRzw26OYJJ1rKqJonM+QwyO4vdodPSlnPHddDOPBgP+aQSQtLciIJ/H3DG/5z
	pdPmFrcuAHsEL48UO1qg6H2CvVHmwzbwPGxHB786KSGuGl9lrTqjZXF9qoYP067xyfQ==
X-Received: by 2002:aa7:9e51:: with SMTP id z17mr90195603pfq.212.1558471998352;
        Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+TW5/fMZQAAIFKdETXtzGvr+Sm6cqSMmJY3iSS7FeEUbZtefPAjtwdzLfJ/Ui9g12XBi8
X-Received: by 2002:aa7:9e51:: with SMTP id z17mr90195527pfq.212.1558471997638;
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558471997; cv=none;
        d=google.com; s=arc-20160816;
        b=b31cL7N692ttBhBV9ePpLnRXkPB87ihV8YgHMv9dRRcXT4xnAFcEKyyF+rrYRdqBRN
         adR6Ub36foOJ+ebvhYKe6DHVxQ4U3Hwpohz3td8jVzkmFWa/5wAuT6yNyg9QcCMhJY2U
         5WTKuHSRDyKIn7ejI8B5rmOxKExgCCrlfAV+RhAVINMpyLxhcc24XnShIxfLIGP4pIVi
         aSrKoZNuSdASO5BbbagHrnUTp6sEthyoBf1Wit+hfDf6CTGCdFFP+Xbn0SQEevmFU7Jx
         f6Mu7ZrfqN+uiFHWwDPq+Zx9SGs2MD/eAr0ufR4VLYNepZk9sIXOJFS7Lzv2eI8IJeqG
         wFYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dBwMVE9KbttCg2XLI675VZQsOGlnJ1c9VoXvCDMDOLs=;
        b=OMuyPzKr0F1dqimSFRmqdJCG0GAg6j8rrUo66YwL2AR3csowbBM3EIOSHp7h/q2Y81
         FChIuV0hjHHKvoiiSwWyEnibv4YQ2zEQCwH0iEMFpZXvNkwmhSwNHQ/UMfUR0SCARTEV
         L+5Fxzm5pVUjggStcmUFtFPZoxhz0Z7gyUboXm3AUDnwoWE4i2nn3QR7LYUbluHQDCWa
         SNeb5UYHRHyyXiLvXnUPoU2Qob+PTBW0rhNWY7iQbNtXRPXSa5uWnPFmmjFyRF0ZmWGC
         RnW8Vx4aDsySXgndFIpQS/KqVH4nmPdlX2F/bZp9Qc5pUwl5++9FggJZJ/eWt1zXDHjd
         LO0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 7si24611937pll.99.2019.05.21.13.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 13:53:17 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.91.116])
  by orsmga001.jf.intel.com with ESMTP; 21 May 2019 13:53:16 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>,
	Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v4 2/2] vmalloc: Avoid rare case of flushing tlb with weird arguements
Date: Tue, 21 May 2019 13:51:37 -0700
Message-Id: <20190521205137.22029-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
References: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a rare case, flush_tlb_kernel_range() could be called with a start
higher than the end. Most architectures should be fine with with this, but
some may not like it, so avoid doing this.

In vm_remove_mappings(), in case page_address() returns 0 for all pages,
_vm_unmap_aliases() will be called with start = ULONG_MAX, end = 0 and
flush = 1.

If at the same time, the vmalloc purge operation is triggered by something
else while the current operation is between remove_vm_area() and
_vm_unmap_aliases(), then the vm mapping just removed will be already
purged. In this case the call of vm_unmap_aliases() may not find any other
mappings to flush and so end up flushing start = ULONG_MAX, end = 0. So
only set flush = true if we find something in the direct mapping that we
need to flush, and this way this can't happen.

Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
Cc: Meelis Roos <mroos@linux.ee>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 mm/vmalloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 836888ae01f6..537d1134b40e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2125,6 +2125,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long start = ULONG_MAX, end = 0;
 	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	int flush_dmap = 0;
 	int i;
 
 	/*
@@ -2163,6 +2164,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 		if (addr) {
 			start = min(addr, start);
 			end = max(addr + PAGE_SIZE, end);
+			flush_dmap = 1;
 		}
 	}
 
@@ -2172,7 +2174,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * reset the direct map permissions to the default.
 	 */
 	set_area_direct_map(area, set_direct_map_invalid_noflush);
-	_vm_unmap_aliases(start, end, 1);
+	_vm_unmap_aliases(start, end, flush_dmap);
 	set_area_direct_map(area, set_direct_map_default_noflush);
 }
 
-- 
2.20.1


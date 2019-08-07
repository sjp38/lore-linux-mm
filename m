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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84788C41530
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 406B8217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rAOpaTjU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 406B8217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E07D6B0278; Tue,  6 Aug 2019 21:34:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EDFE6B0279; Tue,  6 Aug 2019 21:34:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 151596B027A; Tue,  6 Aug 2019 21:34:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE2136B0278
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so57099693pfo.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=GG/rJbu9sxWrFKhw0Cmm6/Fke7RIu6m+R14VJXkJl9YkzpZIwqP11QMZGZRzkPRFo+
         BmV0DAneRKgAx9GCOyz3c72xhIiSJ6HeLLO590DuaIRJhfIY+BW2Ds+OuKq6eG8f7Ix6
         QyY/zwkZz+UadMszbDwLwMYhiVmMaySoK3Xcld8itXxWKJrLbPcjGonmbMijkOp9pk3a
         nL0FhLDqG582Bz7TvN1p/hK5+olTspLgpGTtRC38622/RAjeRswMI7YP66VTjROUi+DO
         4Cuxd3YgRMF0LYgEl6N9l+YfemjX8meVOtXpm+F7jHFSLcWiREOseovUwqZSaKC2AoEL
         nJhg==
X-Gm-Message-State: APjAAAUL6Uyq9BS/IHxrZuMFXJWDHZ1PwT1PUgVx7YNtm+s+rsHvcr/F
	bfXZKLCIpJ9MCurq+3nKVK+6LX2+QzcqdDw6Vc5f90kL2b7hgbW64Y+2k91OB0ROPRNOgZQ+dDW
	n12wgHHcaq7eNUNHQqCHBOu40xPn9UBYCHF8H15sR79nbod2HsaW1RRoMur5Vi8RfQA==
X-Received: by 2002:a63:6901:: with SMTP id e1mr5373272pgc.390.1565141666327;
        Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
X-Received: by 2002:a63:6901:: with SMTP id e1mr5373214pgc.390.1565141665284;
        Tue, 06 Aug 2019 18:34:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141665; cv=none;
        d=google.com; s=arc-20160816;
        b=d3OSwElUmemHCiZisj1kZpADgwAulJgk+JbvLGQ/did4V17boXwiicPVvZx788FM70
         v9XM8E2n9Y6dWxZOU5+85t9J28W7/B0hg4dSZJX+QChvb0Sea93HB1U6lG6SurKEg3DT
         3mHLLEDE+iaefrcew1UZGCVQwjVUM9cyglOWBeBBf1JGC3/TDd0ui96SuDc3oW1th2FC
         y2mahCP5YyOBR10cwnGGwZbyp1yY1Izzbl9sWYu+txD1w9OCW7szRLavpLo/AjGOjrNt
         JHFVAPi+MBzuearkN30JkybYQlyGbUBA7lHEeyNRrM7MdkYiw5OQOj0iZnVxPg9ynoZn
         UMhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=E4YO0cYVRhbPHv7VSE1Ex+lMI/dtVKFhh+Mvlc0sZlS8zG+yHuzTiC1lNen9q1ywWy
         gaxr82Oqc06bDmvo+gr0TL6xZq+spVJAfIyLmVCSmeQj8yod+j7dK+qvI2Dc2d0HX1AE
         dRF6BBDZlPxsvJiqsL/kHTLGxxZu6bZrmZ282kcasFhonCBq7G2ahqS/gekqQjObJm9x
         AevGxmcnoB827kcB5UxVZhfMItzbhZSKi4gFZQBjExAWBaHSfhRA/mAsmHGL24ezQpFd
         6ePHGm4lbFDIkfNW0zBTiMHCmwa4J/8CZ1YuzgwKwMwmkIH3DfteDzi8GiKPfIOZ6iqU
         3NmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rAOpaTjU;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w190sor14765314pgb.8.2019.08.06.18.34.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rAOpaTjU;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=rAOpaTjUSe2mFnrvmhnJS8xKHHDfXHpmD+l4Uv9l8gmgovmdA6+wJqXqls9UsmJQBz
         ep3JWBTwWzs2IRGwW41GCxQWL8zWFiSR6uy1gns5wXkfbjCngWqZazp0XVGWvkIrwV7K
         z/fUXqz3btTykEGkC1n2yQAIcvStpMcGGmLYj4sdGhsYd7aWY+K2HM0TRDI35Ihws22z
         bA5Wn1kxkVVUCZDFZU2yV7yqOW35XJ9lVNcA81nOyQ1MEO7P4qKnD+B4GkGo8p2H58WM
         u5trmpjCembtTJLb3EXiFKzyKJTiFQRUI8DgENKYMdkcBAeXgiFZBUUnvfxQ+ER9+IzC
         DzYw==
X-Google-Smtp-Source: APXvYqy16jzsEED+wwh8ENkTlGqxRvZ0RoyFpGJNp0G/IOpaWMDvDoKlXk8GjrxTBQC2gP0d6Cw0/w==
X-Received: by 2002:a65:4205:: with SMTP id c5mr5563561pgq.267.1565141664948;
        Tue, 06 Aug 2019 18:34:24 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:24 -0700 (PDT)
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
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH v3 25/41] uprobes: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:24 -0700
Message-Id: <20190807013340.9706-26-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/uprobes.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..4a575de8cec8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -397,7 +397,7 @@ __update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
 	ret = 0;
 out:
 	kunmap_atomic(kaddr);
-	put_page(page);
+	put_user_page(page);
 	return ret;
 }
 
@@ -504,7 +504,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-	put_page(old_page);
+	put_user_page(old_page);
 
 	if (unlikely(ret == -EAGAIN))
 		goto retry;
@@ -1981,7 +1981,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 		return result;
 
 	copy_from_page(page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
-	put_page(page);
+	put_user_page(page);
  out:
 	/* This needs to return true for any variant of the trap insn */
 	return is_trap_insn(&opcode);
-- 
2.22.0


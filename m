Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29E30C32755
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB6102089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aCkaquio"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB6102089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A693D6B0286; Sun,  4 Aug 2019 18:50:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F3646B0287; Sun,  4 Aug 2019 18:50:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 869AF6B0288; Sun,  4 Aug 2019 18:50:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 533246B0286
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so52191871pfb.21
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=e64h3p+S5SXMvjdK06rxEU7o57SUnVXPyXi2b41QnWVqYhSjDrRyBXE/fy6fozDHBq
         15/5+ylxlSnwAbEwZLzqiAYX7kMcL2W0PX7VmXsc2gKlmM6/Xrl/ynlwdgsKE10892Su
         Q/wqoFC24qTxMx0N8lhB92nbUM6oyrPlXsaMiRaiAjxHpTv8hiTfS4tX0DmqnmGyz75T
         o8TF0KP4t4cBB/bQ5QP5lSx5Zb42RHV07FY9/JTuldxbE6qYDdbRlYb0WXna1nGHU2kH
         dCb1VMPLtFuEEgOk1jqzSxDpBk5YHI+l00JQ/f41m5Ow7odhToK3Kf6Camka0EY8NHyH
         N9CA==
X-Gm-Message-State: APjAAAWZ67Nkq+12mF/bzWYgDTGuomwe4JpKw3dXYL2ehNJWQq54rndW
	ncM82Kxrb1sAPdC47aubPVTOfeJvQ0YQnz0H194+iyt9kVS7yw0T71u6za2iJNusfefyIN3faeB
	Bo6FhM1SE2PJ2oYE+9rHGcmlwJKU2bS7mnx78oYYm1dGoxev8WexZSMRADeOgotW3eA==
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr138640820plf.72.1564959014053;
        Sun, 04 Aug 2019 15:50:14 -0700 (PDT)
X-Received: by 2002:a17:902:5a2:: with SMTP id f31mr138640785plf.72.1564959013206;
        Sun, 04 Aug 2019 15:50:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959013; cv=none;
        d=google.com; s=arc-20160816;
        b=vDCmB7ZVAfyLKux+KugaRVuLn0vAUVkGr1d1t6pKOnhZOuoqiXYXdL7tRKLOroFWUj
         CjmIo95JnamyKPao5yASvXPZmIh6Bzc4BLWCjg146VlFNvCxuU0HMZAhwyL3UMJluZJl
         RZYnOOb1+7i83dyR9bWNEA7wiMx/qUWyDbGNzeGQ6GAw+VsplHf1SPo9bnMj+hkhfMEh
         ZOuDnsdHf+7sfQcoBWyhoI7cU6P84O4eVSY0xZvLNYm6BhRxOF2SpOvBD2Hpd6L+ggeC
         9iFGSn8zQhsYMIWnVmfHovBAlkE2eOuEL8f5ZZzYdtqYGFEj9IjhYNGnHD4X1IRGIQRQ
         OfEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=PFbK0l3Mx1kAcWy0ZjqmpT0v/KHYGsUJkqFeMsHlhgAuujY81l35wWl3JOWOyQ00il
         RgTaOAIVJaycP4Y+hkWDsdWQpH2DpyIMWYVaU+M1gU7h1RQsQcJMByUAa1RgaUeUouw6
         PkNTAiK9uAgfcpsqHjK7kw6torR3XTtrrkyUCeulCxowOOB3b4G4Lvjx/B6dvScbDSSl
         k7g/2PNJuP06s3h+NlvWDFlGOKxARab4+WvmoRExPMkeIrAT7zCjdxn7ZvpKJBz0gnCq
         C9FBRMMYQZfeTGpQ6ZdMefw1d44lj95bYhlaGTNcNaGrjWsgjkJTya5vnZ8/PS1UavXR
         pf0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aCkaquio;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s96sor18040172pjc.17.2019.08.04.15.50.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aCkaquio;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=cegKTIaYJ+tSle0YiC1yJpybmvJrVZXG5Xryw9OToL0=;
        b=aCkaquioWJVgZ9oxi+kgs0xYn9XvezpV99sLT07IcNs8SpVl8RxEWxB8NfzIRBrjBL
         2B4dJHw2cG5TO6qtCk6u4ZcIwavE5x+pbFyHjAA9Gawo5yJz/cR/RN7KLFsBrzcuwVZV
         WP2fTbo7D/YmdMo3LfJiKW1AjSHc3oDEIZmC59HJW1UrPrOWaY8WJXtwgsxilT0195Uq
         ocw3UqvOC5KedpAwMEgqM2mZYVxGq6/tGgBNtuTtcR3B451sP4Bb3FZmj7gUlwzeWEUc
         XzVXXNThe+NP4na45hxvXL3T6bslaXSJNEyIhO73A4aiizrSPKRgEZ7pYwnnfabRC/Y3
         oqhQ==
X-Google-Smtp-Source: APXvYqwQo0taKdXUQzpI7809Qn44c5UC2qpj3t9n7qUuNadX/5xLSvSBDLCQnHDNoFHPmzlJl8WofQ==
X-Received: by 2002:a17:90a:2767:: with SMTP id o94mr14743655pje.25.1564959012976;
        Sun, 04 Aug 2019 15:50:12 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:12 -0700 (PDT)
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
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v2 34/34] fs/binfmt_elf: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:15 -0700
Message-Id: <20190804224915.28669-35-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

get_dump_page calls get_user_page so put_user_page must be used
to match.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/binfmt_elf.c       | 2 +-
 fs/binfmt_elf_fdpic.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d4e11b2e04f6..92e4a5ca99d8 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -2377,7 +2377,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				stop = !dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				put_page(page);
+				put_user_page(page);
 			} else
 				stop = !dump_skip(cprm, PAGE_SIZE);
 			if (stop)
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index d86ebd0dcc3d..321724b3be22 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1511,7 +1511,7 @@ static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 				void *kaddr = kmap(page);
 				res = dump_emit(cprm, kaddr, PAGE_SIZE);
 				kunmap(page);
-				put_page(page);
+				put_user_page(page);
 			} else {
 				res = dump_skip(cprm, PAGE_SIZE);
 			}
-- 
2.22.0


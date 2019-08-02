Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 217E7C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB41B205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pDDjdXXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB41B205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A48C6B027F; Thu,  1 Aug 2019 22:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 703F56B0280; Thu,  1 Aug 2019 22:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 530E26B0281; Thu,  1 Aug 2019 22:20:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19C966B027F
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q11so40680105pll.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=aqHrofF7uT3BAThuPYFwpUjT00vkycHOwnrnrxLOJjVoT3M2rhjetOrQnv3zZxRDHi
         //LUnQ2pnag8jAVnSp/bkApA9KtuOdvsxemcXWuSy3txmzWx3YpRGppNnbAHpkoOSSXI
         zINg1nzngtUXr8N7XJItMRxgNE10AzHUUlMcM2dWyHTIlzz0zvxOjA7CVBF39baL0xvb
         LWSEK1KNhiSOtH6RGx4R6IieEmL1mRVXycbrmpgNqSwCUA3KqYoEReGyiZGkDhVXzkrz
         CNXgQ1GqlACK9VXSriYJmi2yhLiqpUfpdLSRycAvqTqWeFLgxv97Pgr1oNg19rAfnxRo
         e6iA==
X-Gm-Message-State: APjAAAWmtnALzYRXhN3I0L3Faskd0vJqHOCgPzE8Ss3IZ7Fv2Pv/Rlq5
	tb1grvqDoyGFuJIwePDDTyMw0idkMbSFTtihiAZM6ED/O6GdLyalRQo0a+oz3eVKwAQFitdxw9B
	EmK1HwxkX1GQ8JL6mdwQF1/AWTCVwf73SJ926d0JE7nEUSQStC/Hd5iRsck3ItOGTCw==
X-Received: by 2002:aa7:8007:: with SMTP id j7mr56398806pfi.154.1564712458767;
        Thu, 01 Aug 2019 19:20:58 -0700 (PDT)
X-Received: by 2002:aa7:8007:: with SMTP id j7mr56398742pfi.154.1564712457745;
        Thu, 01 Aug 2019 19:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712457; cv=none;
        d=google.com; s=arc-20160816;
        b=rrsQWFJIe6MFzEwHUZBWKK2w/FzYVNH4TX8N50ne0wlSTOtiD2LkFAFJ3HBjN5vexA
         bdeqhXPc38ad/rT/3kSGqLeuP08IRLxd9ETZwJHX1Mi77fhYd34kcYY6kgsqqksuFd+j
         bUFKBYE0B0r1ZHsixboKnoJ63QuhZGC5EeTmz5S2N0WuUo4AfPixmthbD7o3Df5r0a2t
         31qUT4PXWQdmpRLNiZdHHE7pTcYQ/2Ax2Xv+10lvD9SEYrnlF0T8tB9bEcMPlItR+iDs
         PbuBpf7gceq9uen9NFw6MB5SDfaCcUMbarcgBdT1GPccVV//mXpcZ/kkLUNAV77Tt4ae
         8jkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=mDUqApE7nR3c8mA4uaLVSmzLy7CoCRqldVLS3L2eqyqsSFB4e6NzJwI/M5mCpqW/nt
         UQnnEbh8EF/qDagWujyrwd5jGh6YnUrQI55NnvlhAfpwREZeOhV2yyksVR01pFJTQjoZ
         9AbfUWTlJL05xT6dAD5aQqhg6PvrvBH1pdgUYHapIJA6NvLTjc4X4sGcQXwUdWyHuKHh
         aNaCTs6PdO/vxcmEwiHki7aA49rdCPJ2sLwyce0+mpWvrdf/ZvgcWWTTCxmwD10HPIOM
         nitwMn7myLSnClc5Lj/PJ1LDM/ubGAfdO9Xl55AcDrYhNRSqyu5P83T+qtGuQyi4qrRO
         C7Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pDDjdXXj;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s28sor42923919pgl.38.2019.08.01.19.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pDDjdXXj;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=pDDjdXXj6RFblmUZntZEJACUef7RKkNl/YK04UbkHBUCjruhPz1DvjNzBz0yKiKhLU
         m7TMmjuez3cY0GOJbOTSBK2VUdIVnusEW0vCSFZAYXoD3irkbR/lbNxP1xvdu08hMie7
         kzmRBnIq1D5NEN+UIvAycIBnd5W1b4XDWFug/SXkacUthZGPwZUithvAb6zFZK598+Zf
         KNchzaJdTnwJOaC7HcvTulBYTwt81Zp1hO/B2Q1bZULoUdzowXbHyNeGUScibcu9SmcM
         prETRVYk+V5bEeFpHbvbtuzpFBWpu22yc2ThdO/xtNJdbTSkoBepWkhbKAkxtBTCzSLm
         uqtg==
X-Google-Smtp-Source: APXvYqzmhx2HN9zJqN7W3z+BTBjGONUj50lIUbKXplqq4RVMAlpQQWHUfPagZ1wT+1La24vM3uCr4Q==
X-Received: by 2002:a63:9c5:: with SMTP id 188mr86233384pgj.2.1564712457422;
        Thu, 01 Aug 2019 19:20:57 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:56 -0700 (PDT)
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
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Christopher Yeoh <cyeoh@au1.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Jann Horn <jann@thejh.net>,
	Lorenzo Stoakes <lstoakes@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 29/34] mm/process_vm_access.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:00 -0700
Message-Id: <20190802022005.5117-30-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jann Horn <jann@thejh.net>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Rashika Kheria <rashika.kheria@gmail.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/process_vm_access.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 357aa7bef6c0..4d29d54ec93f 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -96,7 +96,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		flags |= FOLL_WRITE;
 
 	while (!rc && nr_pages && iov_iter_count(iter)) {
-		int pages = min(nr_pages, max_pages_per_loop);
+		int pinned_pages = min(nr_pages, max_pages_per_loop);
 		int locked = 1;
 		size_t bytes;
 
@@ -106,14 +106,15 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * current/current->mm
 		 */
 		down_read(&mm->mmap_sem);
-		pages = get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+		pinned_pages = get_user_pages_remote(task, mm, pa, pinned_pages,
+						     flags, process_pages, NULL,
+						     &locked);
 		if (locked)
 			up_read(&mm->mmap_sem);
-		if (pages <= 0)
+		if (pinned_pages <= 0)
 			return -EFAULT;
 
-		bytes = pages * PAGE_SIZE - start_offset;
+		bytes = pinned_pages * PAGE_SIZE - start_offset;
 		if (bytes > len)
 			bytes = len;
 
@@ -122,10 +123,9 @@ static int process_vm_rw_single_vec(unsigned long addr,
 					 vm_write);
 		len -= bytes;
 		start_offset = 0;
-		nr_pages -= pages;
-		pa += pages * PAGE_SIZE;
-		while (pages)
-			put_page(process_pages[--pages]);
+		nr_pages -= pinned_pages;
+		pa += pinned_pages * PAGE_SIZE;
+		put_user_pages(process_pages, pinned_pages);
 	}
 
 	return rc;
-- 
2.22.0


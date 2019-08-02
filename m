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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 533F7C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EFB1217D7
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lOZaOBHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EFB1217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A61806B0274; Thu,  1 Aug 2019 22:20:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ECED6B0275; Thu,  1 Aug 2019 22:20:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 865746B0276; Thu,  1 Aug 2019 22:20:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5201B6B0274
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m19so31965076pgv.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=TsER7YXORXSLDr2LWeLXX27OOiKfwf77unGLrcqLexv0t7/QLfU+jQ5M8wwCfjm5V6
         NybxOkDXD0B4935fkJbxSD2PkMiUKq4ne0fmlWA0RnJNaTrKSKK5icjMjnsgq2jwYpbW
         o0E5Kt4tLbmnBRSzDJ12bHSY6QZrraL0nYi6VtLtk2tX3h3qq5u3yUi86K8DyVWykSf8
         hgsaAGwlOhcghlX4HkISRds/a9th92YqKoIXlfomGkLOKXH1+v3ApjDyKH0DUGupZQHG
         mmTQXhdcJXc22pDORmvtFeNwpQ0Rhe94A2rrp+jl5Hq5FKlwfPI1Ln3Oox6/fll7BTUy
         Rekg==
X-Gm-Message-State: APjAAAVDDrWDk1SEWmouJXx9+iRg+bOaVF8cmkdVxEkdrRsDpA3u0I8m
	jwr+vsJ6lKJgdLfwN0/qWTGmb75qoQi/+2hD1rSCJv59BV/oz2kCZQHYUdNQi2mOxpDv2IcXveY
	iS7sP9UkowFNuu9nGVCei7a7pxVrO5Z/cxhDnyAtsGf6W/p2+PD9KDAiE2j+Bd9ajwQ==
X-Received: by 2002:a63:f443:: with SMTP id p3mr41586152pgk.345.1564712442957;
        Thu, 01 Aug 2019 19:20:42 -0700 (PDT)
X-Received: by 2002:a63:f443:: with SMTP id p3mr41586108pgk.345.1564712442220;
        Thu, 01 Aug 2019 19:20:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712442; cv=none;
        d=google.com; s=arc-20160816;
        b=QEJ2CT6KIrfQgDyA5zT6qU+4LCQ7osgHMu0EeX8lDICgW9bZhMGGagZjo10W7bCQW/
         uNVkTTMcbAN+IbmtiQEGqT7vxDByEc12NBZujwe27Gb8DM6B4OqCZ50cYoB6g1GmWAtl
         VnLC/SPq3tD4DZznOdF6uaZMjEPYLe3BPvYY2zA7Fxjj3Mtj/9J6j8Fr5qjigJH5cCF9
         HKrVMvFTX2W7R10NyP018MYfQbXGvxeJmf8qzDYSvLnTxppKt9b6gjb6jtY/At+lnrBI
         5Kad/nqHR6QX5HJ/hBBkAFoaCAMSqFrv0zTwOoDXfMYL5XMrjqG/M/sggVZ/l14w0PSn
         4W/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=fk3/76IYLAfxwu14ovmCjgwIhpk/v6LWX8jQdKzzrv8WIW8h6kKL0Ug8W6ThLiocBf
         9OZlXM6hZXulJXKww9g41zi0jwzX8WX1H+IgSei7o/TNe3hjQZDTRr1QHATd4taONdGa
         BEruabIYgJEaLj//GJQ5oNrKYGb8DVMlykjscQHpWku/E6cScIR1dvEbHyJeE469bzJY
         CKqTVl65+u1FyeNfWosuz0vBdIw8Mb+QcWmfedLhrUPJ7OM2n1OWbZh+WwIssBNrUZr3
         f93psjFEehd3h2QZgffTRECYPJwhQANmfQZOLFl4Fi3T+ACHHhkM492GW/+Zt2kCFkE4
         K7Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lOZaOBHn;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor87599453plt.55.2019.08.01.19.20.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lOZaOBHn;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=py067aGaFWqYQnWW3CrL2Yk9VWIyNl4WEpwUsrZ7LgI=;
        b=lOZaOBHnHG96U7CUpGeMR/TMYtjEa4y/ygakLmz0BtnL+pIOpa3C2toztsy8fW4gwW
         tSTtviLJ7HOi9DtUi5KI4XY0WPu2eSdUBZVMSVezuKPLNyCDQwUs6J0/BBBZ+6xhu24Z
         FFakCBm8lWNZ+G5ej5b+50tyKMtD+b21oulPMq7HB8nLNBdaEf18LO4IyZXO6FYAkAZH
         Gf/avj3rVBNxZL42D+4KJvp1yOXbbtpENzFq10jG7FxODtHOFfbvskOX/bZ+DtIk1XsS
         LtXAfdLjn1YTVqg0w1Z1LAlYkVjy6XQT7mshmHFnFkvQYLq3O8bZzk73cr7CrbSrM5zf
         ODTw==
X-Google-Smtp-Source: APXvYqxy0BkUtbl8ULTboF2upH0nHFnxM+Cu1b4hTcaSsJxULdUpLCIdwe/mZoVo5hGjgo4EZJg93Q==
X-Received: by 2002:a17:902:f46:: with SMTP id 64mr130019975ply.235.1564712441986;
        Thu, 01 Aug 2019 19:20:41 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:41 -0700 (PDT)
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
	Kees Cook <keescook@chromium.org>,
	Rob Herring <robh@kernel.org>
Subject: [PATCH 19/34] fsl_hypervisor: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:50 -0700
Message-Id: <20190802022005.5117-20-jhubbard@nvidia.com>
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

This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>
Cc: Rob Herring <robh@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/virt/fsl_hypervisor.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 93d5bebf9572..a8f78d572c45 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -292,11 +292,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 		virt_to_phys(sg_list), num_pages);
 
 exit:
-	if (pages) {
-		for (i = 0; i < num_pages; i++)
-			if (pages[i])
-				put_page(pages[i]);
-	}
+	if (pages)
+		put_user_pages(pages, num_pages);
 
 	kfree(sg_list_unaligned);
 	kfree(pages);
-- 
2.22.0


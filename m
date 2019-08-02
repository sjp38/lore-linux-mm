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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 410B9C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F20C12080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZjBIvPI6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F20C12080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D6FC6B0010; Thu,  1 Aug 2019 22:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 279176B0266; Thu,  1 Aug 2019 22:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 001086B0269; Thu,  1 Aug 2019 22:20:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBB6C6B0010
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 21so47103801pfu.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fEUR/G5OnJcefSlX4AYJWWcgqHhC+JXxEofDOG22P/4=;
        b=X90YSg/b8WXVXiIp43Z1Y7aJgrAx6lO200+j/kYqCfT/trYf/l8/RkYX9kicjYR7Iv
         ej7LrQg/T3EcVtFEW3tjFitBjQzBwlPb3d9R76NsICi02AbTZiOmU/JpuNG4FHrZ/ZIm
         IU+Gf3XHSJPmPmXVeOIAFHwHRNOuUiEvEjwrZBd/sLWCoVdzynNyRX/JXi9zgnTDABD8
         sLIggs7SRBIGWhavNdlKtr/TCVTkmrAEXFjjqkvJrYix+bbWsRGv+p1utr0ineDlXyAE
         g5Gg1cJeNQUF10HvcPJf+HuUk/yz1lmnckXfGQ9qUA60AHg5qnRFyrrkPtqtc0VgR64q
         CNwg==
X-Gm-Message-State: APjAAAUq21dLDJ+o53pJfH/PvGk8gqV4q2Cm8phBMijVgLnO1pY8+niC
	KSxKyXG5GKgoZGdDbPCvqhV/HpT9vfr53RskDXzqAsZXOkh/lizJi4FG1TSb6TgA9A+yLlzltCH
	kXAfzl1HwvjWg7tXA2cU/8q9OBImm4NZHUlpRD6JfCkg4YbcM3NW8SegK3pkFU6LRVw==
X-Received: by 2002:a63:7b18:: with SMTP id w24mr121465081pgc.328.1564712422310;
        Thu, 01 Aug 2019 19:20:22 -0700 (PDT)
X-Received: by 2002:a63:7b18:: with SMTP id w24mr121465046pgc.328.1564712421486;
        Thu, 01 Aug 2019 19:20:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712421; cv=none;
        d=google.com; s=arc-20160816;
        b=0rZg3+XB6hMMZfyvWVEApNutoMrfREvClOWnBBWB6pVF2NA/VzV5a4T1W8+sEdpIJD
         JP1fpfdgMg3ENzuO2553oDwRfQguHKipHKYCvg/epMFyrocnqaFtHC+gNl/cBzBsJXXu
         vr4NUUEkHERg5NJrSBg3uugiXA7CjmCOVDDOTQIPa1MXtsH9LrnhiZIU8WxPm8M4lxYt
         xKmrzgKVkSA5ENNghYHuN58W9hj9RrMOcip8isUC0261a3v0DQKTK25WBbWp1FadTxCg
         mISOvYz6VaY1iYvsMry6r5z8CJTv7E5xHDAzlqD+P/sqqi7OwbynNAdduP/HIL/p3aOL
         LOwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fEUR/G5OnJcefSlX4AYJWWcgqHhC+JXxEofDOG22P/4=;
        b=EwmrSljOZY5q+ZOaDHS1Yu6geiq7ke6FfAhlXe8fUP49GF9oWKEcNVvQh0vgZ7zeLX
         1IiWX04po7kS05qkXyFLUodj3XGwDuk+Clt99xPLe094ItPTR+EPN1R/bmkqQoX7xIaH
         tIANx6ruTYZS8TLRnjsDGNNeOmoA8cDpJchrp7U9gdr+YnY82VP9W5iQkMVI9ICn0A2N
         NoAxcOndMwLcnVwOiqElu2SRiu4bwmwlZ3yVcnm5VBcjw9ZUx+j6xN1kmjeXPDPnHIwy
         2maJ1zUXmm4txzNoDzPc4bNtmT3nDU6tEsOYbMTbabsyipXTr/qSFusJ6GV3xt1fLLlM
         X95g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZjBIvPI6;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d33sor89161499pla.46.2019.08.01.19.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZjBIvPI6;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=fEUR/G5OnJcefSlX4AYJWWcgqHhC+JXxEofDOG22P/4=;
        b=ZjBIvPI6FGYYuQaoM3wYb6xPjNep6A1qdBgLoxOD+angQDRZC9mN7qZBiGsA4x1Mmk
         DVp0b1Fq3km/l8LFUFJZZReS797zF2kYF9KrMWUllVa8HFfcUrM1hAE1P/qQjXzrMnOX
         JxD/xFl+WZHXSEuAGF9iElPEIqC+TRo873joNlnRMAHY9AMqSmLW3nsU27bTpXhcFKV6
         4LeM2yIf45e6IoMit2yX6aFzmLhkspb/EkG8Tlqf3bZNN4WeHI7tMYFctQdF6liMtwoJ
         IvfT9HS49sxx2bYOPNOBswTMjccuTwXWnzyhwEMT1ktty7/Al6mbgY/88Wt++RCGQUor
         cVVw==
X-Google-Smtp-Source: APXvYqx7CDlh0PC+iGQbvpFabXIK4hA95kcB6ECyCRgjU7tdLEhAXCZnA9jGvinS59yHHVq1pirulQ==
X-Received: by 2002:a17:902:a409:: with SMTP id p9mr130268364plq.218.1564712421229;
        Thu, 01 Aug 2019 19:20:21 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:20 -0700 (PDT)
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
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	David Airlie <airlied@linux.ie>
Subject: [PATCH 06/34] drm/i915: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:37 -0700
Message-Id: <20190802022005.5117-7-jhubbard@nvidia.com>
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

Note that this effectively changes the code's behavior in
i915_gem_userptr_put_pages(): it now calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christophe Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: David Airlie <airlied@linux.ie>
Cc: intel-gfx@lists.freedesktop.org
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/i915/gem/i915_gem_userptr.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
index 528b61678334..c18008d3cc2a 100644
--- a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
@@ -527,7 +527,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	}
 	mutex_unlock(&obj->mm.lock);
 
-	release_pages(pvec, pinned);
+	put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	i915_gem_object_put(obj);
@@ -640,7 +640,7 @@ static int i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
 		__i915_gem_userptr_set_active(obj, true);
 
 	if (IS_ERR(pages))
-		release_pages(pvec, pinned);
+		put_user_pages(pvec, pinned);
 	kvfree(pvec);
 
 	return PTR_ERR_OR_ZERO(pages);
@@ -663,11 +663,8 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj,
 	i915_gem_gtt_finish_pages(obj, pages);
 
 	for_each_sgt_page(page, sgt_iter, pages) {
-		if (obj->mm.dirty)
-			set_page_dirty(page);
-
 		mark_page_accessed(page);
-		put_page(page);
+		put_user_pages_dirty_lock(&page, 1, obj->mm.dirty);
 	}
 	obj->mm.dirty = false;
 
-- 
2.22.0


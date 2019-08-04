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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4196BC32755
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDEC621841
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WszdJ6eS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDEC621841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B529A6B0272; Sun,  4 Aug 2019 18:49:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB74A6B0273; Sun,  4 Aug 2019 18:49:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DF1C6B0274; Sun,  4 Aug 2019 18:49:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58C3A6B0272
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so52154480pfb.7
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=WnaK9xFgACvkrwYoi03/CBSLpzKyRnjwe7gUeBjpc8k5ZfkuBjxme59vDVLLcpBRT2
         TmEeFI6N2K/YaHivx604quxBRG3r7LMHqUXfxPpGAOqKGCnfHCj9eJkxeSGcZOQVrogK
         Lkzq0ulqsyjVcD6m/TkZ76c/Iu81FYrwHbdZcZVYs1B5B420DNjimfUUJSihVydy0+HH
         tCVnJ2g69OeEG1shRvb72YmrAWkbNRWJok62hVsj0GLt2VtBpCCWPba0G1m73Z0nP+Uw
         iJnRMKSL+lVZkI9IPeSXxs1s6/urgA4mL2MUlgr7IhZiGCstaj673GNO3zJBbBS5qCRf
         0viw==
X-Gm-Message-State: APjAAAXaAyFCaso2239EYuyudM5GfOKDDShNL+DTaPaTJMkCRdXIEa8b
	30KbgfCI/980Ve8Xffpk0BFXD7t8r4cG02aRR0QLH86taXlPxUufTIqHLdOoLvFmnOMukMwg3yB
	HYXy7k/uAz7bV2FivaiV8wz0Nwxy1+LbNBvqBLhwAiw8++QjIhYTeblie3g297/kbsQ==
X-Received: by 2002:a17:902:a01:: with SMTP id 1mr58331378plo.278.1564958989072;
        Sun, 04 Aug 2019 15:49:49 -0700 (PDT)
X-Received: by 2002:a17:902:a01:: with SMTP id 1mr58331337plo.278.1564958988282;
        Sun, 04 Aug 2019 15:49:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958988; cv=none;
        d=google.com; s=arc-20160816;
        b=UeBHASjJ38OTnClh6ICklcOUYc4Bvcyz8zFLu/d5Qc4/+WeUE/iM4R7/0ErAnm6cow
         0qSSZx0txBKdOXRnwtOGoCARTFasnd1xuI6WlT/f+3uC86DF96TMFb8Br2UThQdL/Tj7
         zgq2CnI8xSHIDMSpiZtm3oBtA1kuSWUE1OMHG6ZyswBeFbukhDShOCPuhpHn/1qWV3U2
         840xqIWNsaNoopdHqgq+zPXe/lcyzrwiGgjUEzN0EaczQL9W1alAyyu9dn8qys3aISTo
         KSjzvZqm5l60WsZK1w56yDHYFwA1A3kcGE+186zLb7niiFZBIsxqjxHCgEn8ITB++19I
         7EFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=HZ7OykTNR7BpFxCCQq2Ir0x7SHlUykFyhGbgdz1hcAwWHF10tLBWqHNHNioOZnD1Qw
         4cYZsAPMOLw7Ipal8M1CZvRY2BDZbWRV/cGyec/0HYPcDccdWBfns+C2PIqjQyhvdg38
         WtciLTxTN/j3wC9gddr2urEqkbiTYyvCszfbIHFlNd4JHlRzLUTS/KPJDieWRHVu674j
         HmqdA/bb2VZS9bacMZIfg7sGgb87DN3AzKTsDY9du3uPIPPXqKcJv/oHN4/K6qt3fS8i
         Eps/6GYrOoSSFZfDqhP46GJf+D95Pz49UxqUvQ0wi7Zh6XLlg4i4hkJM+DLzz3guhLl8
         1ajg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WszdJ6eS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor57315921pgs.79.2019.08.04.15.49.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WszdJ6eS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=WszdJ6eSiS6l8Z9/5N/vbNe3jNFvMTjmOIbyGI43X/lqn/ujHi2UxXu88CH1bmo3Pr
         auVxGpa3TkNwR224TaYOB1ePcD+ho6gM00/37bER1kKjl0rL2SnnzYvGvu3vN/SXHfk+
         wtblnQHWP5rqAtZxjvFWL+wwPm4ICxkBWE6EXcMAD+BIssgCDDepKV59lPfeJfOzGgFr
         KW9V0+2vgt3eaIWXLk7U/hy0iBaj5GHPE+ZLhIwPVMA8/7B6uNEiy5Dm26EoCBxtBU9T
         tUYfOzYB8/UlHywiUxmEUaaGe/mgWuOGErPZVtfj1mQo23l9R0hEud7H5SM/CqJoFOsO
         zJVg==
X-Google-Smtp-Source: APXvYqzXOrOAw0v6KK/XGb3+LYPhc4s7KW/tJCUCwczRKyA5tVzLB0NIrofddWwwfme3ueTIgYzfbg==
X-Received: by 2002:a63:3407:: with SMTP id b7mr22111094pga.143.1564958987901;
        Sun, 04 Aug 2019 15:49:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:47 -0700 (PDT)
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
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Kees Cook <keescook@chromium.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Bhumika Goyal <bhumirks@gmail.com>,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 18/34] fbdev/pvr2fb: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:59 -0700
Message-Id: <20190804224915.28669-19-jhubbard@nvidia.com>
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

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Bhumika Goyal <bhumirks@gmail.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-fbdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/video/fbdev/pvr2fb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 7ff4b6b84282..0e4f9aa6444d 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -700,8 +700,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	ret = count;
 
 out_unmap:
-	for (i = 0; i < nr_pages; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, nr_pages);
 
 	kfree(pages);
 
-- 
2.22.0


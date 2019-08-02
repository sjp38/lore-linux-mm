Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11C7CC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBD9D205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FnXZWigm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBD9D205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A8B46B0285; Thu,  1 Aug 2019 22:21:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55AB96B0286; Thu,  1 Aug 2019 22:21:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AA326B0287; Thu,  1 Aug 2019 22:21:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06C5B6B0285
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:21:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so47101958pfw.16
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:21:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=SxjvfLl8cQVq1RO7h1qj6MditM6LX80kP0SAPkpl6K6kXznjiL3eF+cDXc7anZe6G8
         xOLfbI8ejKMavJX8NVIxpmjto7c/MElrCE9Zjhurf6Szm+mmjQdlfyO0BehEPD2rlAea
         pM9O86zJ/VsLMU3GPx9jBZpPQ7S0gyxt35Z53TcwRalKUmsKdUz6H0XV5XC2nAYIO9yN
         tbyFZOiLMJvI+uCrWKfURyXJeV8RiV90n9Y7zRf+Eop32I3myTEGphpq4KSM6xEfxq0A
         HcSUwKUFx6aqVtZpxNLaAqr5D2WfSdBWZ0Zta1pTWm4DQ9i36Aok12dHbAxN4dSDS5QR
         tw6Q==
X-Gm-Message-State: APjAAAU0UtNHN9cup7R3yiBEzkFzaqOe5SH5xijFr1pyITMl67GcxCj/
	8AghySOtlgaIGKAEUMxR72MN/aA4Dis1oaoTI3XfLCmooPcmKmyOc32e8XLLw6qV420OWNbO1lo
	WhlRq96oHelhRmmIRBCjLRoxGtwjqLuFgUlO/ZQBF3gWxd6A4nI8miTKM6Tkbnd/M/w==
X-Received: by 2002:a63:ff65:: with SMTP id s37mr79763942pgk.102.1564712464629;
        Thu, 01 Aug 2019 19:21:04 -0700 (PDT)
X-Received: by 2002:a63:ff65:: with SMTP id s37mr79763909pgk.102.1564712464024;
        Thu, 01 Aug 2019 19:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712464; cv=none;
        d=google.com; s=arc-20160816;
        b=hO4T7GV5REKoETiPuL7R/50NSe32GKq99QG7GYYCjk53SkTF0rsRG4CAI1TgqJSRn8
         7qGIpSAmlfVt4fpPSjvbuppGxV1eFXpU5UjIt2ipDAB6afc9JBoNA03IvKr4qhcXyZkr
         tboeXVE+hnieENQ2A6Msy+P5cIpwFsfALGupE40gGWy5iGLJTrHFDsLX9v45t9bEbG78
         5r/0ul+FjJBhqnd4KstyZ5K8obsnoHJB7vRsNCqLXqd5eg6Z2tp9HeDfu8jD6Bwd026/
         RiTG7Obh/RLgce7DfXef4YJWaHdqgM8Afr2XMHlWKhfbyoGdMnl2bfFAzCrd85gWMkqj
         PpZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=crcKoRJ4LC1W9Y4b68xnX4fTBDvQi/s5hhN+Mc02wOPicSMBxqmt3E3fmX7DRkZYmI
         JJnOaBYgh8L56oGfV6qCXftd235BLEbzYYRnCFgFTyz5gHtzlUmbsmjU2pbne+0RogG/
         12fDONIgT025z7Z1Sz0ahzeD7gb5zPYJpHkmsdXCBb9j9TW/EGp4zNUQ6OcGiqqqujYp
         Mc7nBNEBTbzCTwBSiMwrdGtGV+sXitS+SvsilcYvFCoEpJfFFmnZKSiE6QMM1yXng2Ud
         bYBsNErx9HWo/gpgpxYEmSsQ2ue+5/JyL+Eh7KgnuRjvCPNEFFfXOhjQzkIIsEfSTR+I
         zSFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FnXZWigm;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v11sor8568514pju.18.2019.08.01.19.21.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FnXZWigm;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rv0dCo+fqAQ13SgPxACDlFOa16RsKjSPlFe+eBoZNRU=;
        b=FnXZWigmXks7P7vrWF7fKqdJ1mEC+gV48nu3UaSpxK4YL8v+ZyKfQNiGbSuus211Io
         +fy2JCOQXe0u+yVyht7IUnGNiz1ytce226/iQ1Wda7n+sWhgorrLFCh54sw2yd22N9l0
         AXL2/cPWN7xjLjU338yB5B7ZEpAB76ymwzaqr46s48M64gK8WOGJ87UIWJj0TMsT00ZG
         rYH/3SCw5LcEELiN57lLCnYUd8Lx6hylUyDzZKFYq9GvzONQ8cx9AYXJHJgmouhXLCeg
         1q2sn/m6YtRZPuqIGm/1JYTBARn6QQkL/1+apRqX4+bW7vcNXDLWp8NZbJWw7fVf637Q
         Jc5Q==
X-Google-Smtp-Source: APXvYqw6pZRI02L0RsJ0l51BCisQWQi/OHFOULF/U1jaQbwym1DWFopp5ASpqFdR23hpYNhrKVILMg==
X-Received: by 2002:a17:90a:bf92:: with SMTP id d18mr1939362pjs.128.1564712463758;
        Thu, 01 Aug 2019 19:21:03 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.21.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:21:03 -0700 (PDT)
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
Subject: [PATCH 33/34] kernel/events/core.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:20:04 -0700
Message-Id: <20190802022005.5117-34-jhubbard@nvidia.com>
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

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 0463c1151bae..7be52bbbfe87 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6426,7 +6426,7 @@ static u64 perf_virt_to_phys(u64 virt)
 			phys_addr = page_to_phys(p) + virt % PAGE_SIZE;
 
 		if (p)
-			put_page(p);
+			put_user_page(p);
 	}
 
 	return phys_addr;
-- 
2.22.0


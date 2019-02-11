Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8508BC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 480382184A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:17:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 480382184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04D38E0152; Mon, 11 Feb 2019 15:17:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB43A8E0134; Mon, 11 Feb 2019 15:17:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA3E18E0152; Mon, 11 Feb 2019 15:17:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6218E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:17:05 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y1so149226pgo.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:17:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=cKOiE/bY4B9gWcNeRzZwh6QEdod/wPSIL/JDH35EJnc=;
        b=p/oxhwp6CmPdwOGidYrM/9P0VbkMfjh811Q+7qV1dijhrx5vy673p818ZsBCyZqZg5
         4AfRm7kKIMcuBaCPlTLONqFwxqVIcp3n9aq2g99eMdoolgMcvICrwr5N7erVvTjCXsmm
         ADFKkeHquGDjGUAtBOrwato6bosrdNVBArQoaC1hD6bG/aGFL3K3sN+VvXce+UXJqqOY
         +oOWy3O7ZoQFepJFOge7tFWqF4CmcszyTLoMk51oHPLBXlogJItGcFaYYUTNgc5g4par
         eHQOKKWVyX8clYPfdld45mpV+yJnTxRhy75PyJhUgpPYImhGX8l06ywQleMxwW5ukHhG
         gToQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubYHQlJkPxauNWYzCx96SU+gMklPHmuN/9FlQ659IX0IgTmoB+h
	CFVdvzw5MMHvm177uQUNs1T40F890LgsVuvssjcHXoqbs8+W/DKYRQZ4U4gSbBlZuLHArEmv8EX
	BAUZxMss6toL3No1aCPSyR7FusbjUw3LOQCWPFmUvWb88wOCwREmQouU32meNd926dA==
X-Received: by 2002:a17:902:887:: with SMTP id 7mr27151pll.164.1549916225244;
        Mon, 11 Feb 2019 12:17:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDH4nPAPdyXDghlMC4mP5PQJAxcFOS16PCHhBn/kPVbBPCNKfqx4rq8h0mbHo24KMx2IwE
X-Received: by 2002:a17:902:887:: with SMTP id 7mr27114pll.164.1549916224627;
        Mon, 11 Feb 2019 12:17:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549916224; cv=none;
        d=google.com; s=arc-20160816;
        b=jUyNLgTYMJixL3N82Ft73Ktw1pfcKvOvcclOLFNL/frV905SJLSSbj9lEC+DJitmwE
         v/cBGcXfY0IizTYVqRg6LBTj370mZpllZto3jARYZwflP7vfM2t8bhYH8qbknJkW/kn4
         fdekiPLxxvcjigKT3geY5LLMs6Q2o5g90VtEIlEwIqCOf+LVpE3hxhqD18mJvPtrqo29
         4PhQzckg8nRDmGkJf+SWBSGz9EPpX6IAPev+TvQ0dA7pSVE0vM3MH3zOppZ6TmZE772b
         YwSGdr2hne7ccNjl6yQmV/Q69lUCxJ1YaaefxKeqVWXTDXFFMtxN1kD+zJBxgR0l/co6
         w4Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=cKOiE/bY4B9gWcNeRzZwh6QEdod/wPSIL/JDH35EJnc=;
        b=cAiyPz1wLxWbhdznBjJPCfzRr4sL2jS6wm6HMsS4lUnKmhSggSRlcFYA5VD6+Pz65G
         /3fui1adCXCBf/2HpwZsREndkgSUuS13GHDF7fcbINTbQ/tk0c0I3bSvgv2pPyegvKkf
         nVZTL+mE9ODe57m6Se8o04sgbhM5tfFIt4LMVmXoVVRcn8Ko4rwS2yTvyeZr85FVG8U9
         Q8XTnFs3/Y0DebwuOo/A3+tMbKbiY3gaREAfEApbkJbXBvLriwBbcZOnC6iLXAyBQaD8
         /qnaqXoQn0a/wAVwUVa/2PjXIk4Mfr93ycxErmVYDTxZSqcnxCKzvcEzcaMtQFnspOQ2
         9/3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v1si10376043plp.12.2019.02.11.12.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:17:04 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 12:17:04 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="319498277"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 11 Feb 2019 12:17:03 -0800
From: ira.weiny@intel.com
To: linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	netdev@vger.kernel.org
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Date: Mon, 11 Feb 2019 12:16:40 -0800
Message-Id: <20190211201643.7599-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

NOTE: This series depends on my clean up patch to remove the write parameter
from gup_fast_permitted()[1]

HFI1 uses get_user_pages_fast() due to it performance advantages.  Like RDMA,
HFI1 pages can be held for a significant time.  But get_user_pages_fast() does
not protect against mapping of FS DAX pages.

Introduce a get_user_pages_fast_longterm() which retains the performance while
also adding the FS DAX checks.  XDP has also shown interest in using this
functionality.[2]

[1] https://lkml.org/lkml/2019/2/11/237
[2] https://lkml.org/lkml/2019/2/11/1789

Ira Weiny (3):
  mm/gup: Change "write" parameter to flags
  mm/gup: Introduce get_user_pages_fast_longterm()
  IB/HFI1: Use new get_user_pages_fast_longterm()

 drivers/infiniband/hw/hfi1/user_pages.c |   2 +-
 include/linux/mm.h                      |   8 ++
 mm/gup.c                                | 152 ++++++++++++++++--------
 3 files changed, 114 insertions(+), 48 deletions(-)

-- 
2.20.1


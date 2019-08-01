Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC62AC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA03421783
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VXApa2bK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA03421783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2259D6B0005; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15D946B0003; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008BA6B000C; Thu,  1 Aug 2019 19:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDCF06B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 19:47:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 191so46823384pfy.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Vg4QzQ/7F17W/rUghukJhcqs5s9RAye4AZfxR//QV0o=;
        b=AJnz5Kj6AGTNrnBa23Yy4YReZzulEv0ZcA8Slk7MLKKlf+jIECgFDjae85+JKS3pN7
         Ei4wYeSP76xX0KZM+4yWifwYgamojm4Ubw87c/Y0ALS0odtL00fPqlIDEeqvtYjsNLu+
         qnwtQP/L5prjJ6JlWDeiRIJWPZBIgRaj1f95zqOn2w4/aGNoKl9oMgmYok8OBPgTYrqd
         kcKK78pVm48HDG3pMeKupRD0O5r99XA1HOHLVHkPzdtt+Ul6KOzFce/5qvBsx85KlBZd
         yUt+eZ0UHVBD93yGKA2k9KFrckreMbTLfoD7JllKd6S7YUyxKbJhut7o7swNCvBf5tjc
         SiJA==
X-Gm-Message-State: APjAAAWywLtCLjN4EaalTEy7XDVLUDL62LxOAX6RZhdcNTWE64difQt0
	JqC8RrDiolXBqaoPXNNvaH3b7fUOHHzWPj42FvD0CwSLCiZDOayQlFH99R9GsSNw1bx648l4JNi
	UwaiWSveLHwPiHhRduJUkNO5QIZIX4FFT+2nGABYriWq3m8UoWDboh7WUuf3CHhKFkQ==
X-Received: by 2002:aa7:8b55:: with SMTP id i21mr56537556pfd.155.1564703265430;
        Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Received: by 2002:aa7:8b55:: with SMTP id i21mr56537230pfd.155.1564703260356;
        Thu, 01 Aug 2019 16:47:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564703260; cv=none;
        d=google.com; s=arc-20160816;
        b=O51c4XN1ro2+us5Qcct41V/kAGD6Oh6bDmZeEeRSiJZWt9BUqYnvK/RJLE7FJzdrt1
         HnkSASRL1YwB32rBmp9hqgY1fwKzFQI0UEt1HFDD8tPXpmUa0JYVoUKsT/fdoVBjmejs
         LlRZres9JRho+9ByoUkl5Oeya01j0khzbiYCi/xnVl/Uu+5xNKFoG8rQIeJRTXV6ICqw
         qDtFqgjugjz0XjS+19iuapfca9UtUbdFQbr2S7H5x7UTxsnZQd01t9r+1PZw2jRsFc4S
         NyWLUQqpUwKcpk65BuwZM+0PmM0v3iwAKICRnSkZyNjvz2FIteAqRbh7UjEO1O32Pecs
         8olg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Vg4QzQ/7F17W/rUghukJhcqs5s9RAye4AZfxR//QV0o=;
        b=emfGgzBgZpMD6ri7NlgOq4ghiWvl0YYniri2lKUD8G27pSODZqXat/TPryYAx0zAYL
         6wnjg0Nn+rZV90zSwasb18SflSwQdoe2CFOoDKVqUC/Ip1AtUzJDtUbImjF8EFQDfgi2
         krc9vXbx2VYLE51JN05vSKe896etEnKFw0TRscerZjMQn9sCjZ5aPrqQPNFq5VRbD9YI
         97C1TjTBobQYb2kGhKGWK62OLlSPy5+zBLlQZ8etLzCPQ1gX8Gx3XN/bHznnz4IDu7DT
         Sbu4q1dboycWoCLligMNJlf17ZkoyPmxE4PXgUSRKCaHZqtBVt6pMp4oBVHByrzsaXKx
         vY5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VXApa2bK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor48885171pgq.25.2019.08.01.16.47.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 16:47:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VXApa2bK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Vg4QzQ/7F17W/rUghukJhcqs5s9RAye4AZfxR//QV0o=;
        b=VXApa2bKtU/+qjnj54No4w9jeBNCs/2ouRrzJwhVcI9bqY8FfV+lWiNYwbsicvbOdl
         gMkx/W/bNkCq+wNmaOVEypvcnQYCBpMtS63geb51KtbNv6tA5o8AavZ/OkslLikGEpN7
         TZ6jcPk7YupGsAob95DLycEHEidCNCO3vJMcSsJfyWJdg5s82DlsF0VMt6NkiZ36SD/y
         ewsev+xHhO4YL7/M/T3jKGSqWEQRwKTVpHkem9aFrBpI2POpX89SLC42HKEqRQxV6KlB
         XyXV7Rr5gxVbGs2rlTCzOJkRGFi8/OkuUi2i3rMP7bEQkC5KSNXB3wChRcRIy1jl586G
         iecw==
X-Google-Smtp-Source: APXvYqwHoHG6JQ3jRjRVySMONqToxLBPphS71bd0Tygq+HVgAHEylGaHC3u+H2i9mxt915ePZzuW3w==
X-Received: by 2002:a63:e5a:: with SMTP id 26mr117179570pgo.3.1564703259868;
        Thu, 01 Aug 2019 16:47:39 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id q7sm79090792pff.2.2019.08.01.16.47.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 16:47:38 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v5 0/3]  mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Thu,  1 Aug 2019 16:47:32 -0700
Message-Id: <20190801234735.2149-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
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

Changes since v4:

* Christophe Hellwig's review applied: deleted siw_free_plist() and
  __qib_release_user_pages(), now that put_user_pages_dirty_lock() does
  what those routines were doing.

* Applied Bjorn's ACK for net/xdp, and Christophe's Reviewed-by for patch
  #1.

Changes since v3:

* Fixed an unused variable warning in siw_mem.c

Changes since v2:

* Critical bug fix: remove a stray "break;" from the new routine.

Changes since v1:

* Instead of providing __put_user_pages(), add an argument to
  put_user_pages_dirty_lock(), and delete put_user_pages_dirty().
  This is based on the following points:

    1. Lots of call sites become simpler if a bool is passed
    into put_user_page*(), instead of making the call site
    choose which put_user_page*() variant to call.

    2. Christoph Hellwig's observation that set_page_dirty_lock()
    is usually correct, and set_page_dirty() is usually a
    bug, or at least questionable, within a put_user_page*()
    calling chain.

* Added the Infiniband driver back to the patch series, because it is
  a caller of put_user_pages_dirty_lock().

Unchanged parts from the v1 cover letter (except for the diffstat):

Notes about the remaining patches to come:

There are about 50+ patches in my tree [2], and I'll be sending out the
remaining ones in a few more groups:

    * The block/bio related changes (Jerome mostly wrote those, but I've
      had to move stuff around extensively, and add a little code)

    * mm/ changes

    * other subsystem patches

    * an RFC that shows the current state of the tracking patch set. That
      can only be applied after all call sites are converted, but it's
      good to get an early look at it.

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").



John Hubbard (3):
  mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
  drivers/gpu/drm/via: convert put_page() to put_user_page*()
  net/xdp: convert put_page() to put_user_page*()

 drivers/gpu/drm/via/via_dmablit.c          |  10 +-
 drivers/infiniband/core/umem.c             |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |  13 +--
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c        |  18 +---
 include/linux/mm.h                         |   5 +-
 mm/gup.c                                   | 115 +++++++++------------
 net/xdp/xdp_umem.c                         |   9 +-
 9 files changed, 63 insertions(+), 122 deletions(-)

-- 
2.22.0


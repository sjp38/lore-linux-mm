Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E757C32751
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA4702089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u39I0RWz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA4702089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 828C16B0003; Sun,  4 Aug 2019 17:40:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8D96B0005; Sun,  4 Aug 2019 17:40:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6532E6B0006; Sun,  4 Aug 2019 17:40:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2926B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 17:40:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5so51328390pgq.23
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 14:40:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=u7QfHgAZJphiJkiML+n7+9xiXsnu4L5blHeWg2XiOgc=;
        b=hWXNKhFR+1dQqmN9xDFz4dPj13IaE9r3687EgNv+yJ9GJ/UyD96Wiji/PmaM34/wwB
         40qwp29w+n9vOsLYdIdhsJ6x3OLU76X2SX2J+QIEaI08EWoFmMP0IF0pJHrvb3E9Ex0g
         IdH+yCXeMw4MYgQ+GRIctxALiGvDyVMQt4+6LIBYCcZVxgXFOxockqMC0Db6akwAXK5p
         RSAswA6Wo3l0X+SU/XnP84yVfYkHqeTxzAaIG4JsVJQxoD9J6d7sO+eN9uKJAGErkBPD
         Mw94GaAiQEMH9U9WF+YKB8nNSWiYaBR6VuccoYv7w1/6RtdO3VtIag9wdhKyMpowOXJ/
         xbzw==
X-Gm-Message-State: APjAAAWwithUVAt7Tx5sBBUxzwYzFUx+cfTccqbp1Mltk0SNKWIhHDYo
	w2Eq4bfIMr/g8EaZvN+konUPxwCx0j64clKxYg5YdxKWdhTAwsDXCMs21jVpAOisFz6fWZzWp1l
	RsEvO7WFlRSvJ5po90MlKJf7D0Rqre2/gDkkahG6QaYxDY0/lcfzz0tvdX5OQM4OnLQ==
X-Received: by 2002:a17:902:1129:: with SMTP id d38mr143223252pla.220.1564954846707;
        Sun, 04 Aug 2019 14:40:46 -0700 (PDT)
X-Received: by 2002:a17:902:1129:: with SMTP id d38mr143223211pla.220.1564954845921;
        Sun, 04 Aug 2019 14:40:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564954845; cv=none;
        d=google.com; s=arc-20160816;
        b=X/YsOi6lWyNZnOVF4NOhiAAmzlpfuIyjd7iI48vVbYLEwwl505w83DJy7NGMH41XYx
         8j042GbCtcxLm+BziOC6iGsWwYBP+sPtWz17Z+0jNxGF72n8VBmDmdZk/bPGlRVFZu76
         kkmzhz5uTJmqJehjRVIldlskMWHnlz3rcZFMzvbbnWiuIARsm09xz2oGQKpImY1wjc9Q
         X04zqAn4v6VrUqt9o5pQ99dqVOOK7Xjx3XRzJasMiH0sA9RHg3kVah+53xzioPr1rhmH
         Mu78XwLCzTv7cRnISUHHxtXbo85tj8O1xRPEG6VCdwt/GyvOrSBKfHZOuzlzbJ45CPFW
         njrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=u7QfHgAZJphiJkiML+n7+9xiXsnu4L5blHeWg2XiOgc=;
        b=hX1sFiu3pocv9T6KdGEsnHJvM8fhcvHfyjCM7waGfkTz/z4nSvgNWk6MHobDEc1q6F
         GhIM4kEQkrac8FpMXZ+O7FPMRj/PfhWl8B6lHBvVpesWsNWSedj7IxU5uNXE4VcD0jDj
         E/NVrKwYNmMMcMAOPwd3gW3F4Q/IjsWnaUD/YHAIGhiMkL7yuX6nnqttj7AgInKdwwAg
         SjcrBXksNBrXyOy2BA7HPZmNTPUbiOMeyQvKDNRPDMWqv0XfeS89OJznVGBOA2/74YlO
         e/YLzsKhNhOmlXklFXiSGm/5HZ3RN1u45PR0NpxlJnDF+Rh/ayEeDBiPx2Jgin4A1Wcg
         gyuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u39I0RWz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bx14sor18439356pjb.21.2019.08.04.14.40.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 14:40:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=u39I0RWz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=u7QfHgAZJphiJkiML+n7+9xiXsnu4L5blHeWg2XiOgc=;
        b=u39I0RWzXaT9LZiMOuWXB1YMfdm9l0k5XildL+8oy8WG+Xp+HlNRUNYjNYcsIgMMTB
         ZpD/HwYg5a0o6ahOx9ZYRbmJlZZ3NLwUfe/ls4mO6JoAFJIx/C4wKRP28ihiEUB5VjhT
         D58n4BNw9c55IlGQPpiJrVPRnoEMM0g6/Xf+ahwHFl/B88xU2qGxK/pemUTTRjimFwRi
         t/D8fcfMolCCDTGQO+urRxWr1DbAd4j3hCpOP6OcV/VT/muTPpaFTvV1+DiX2EdeA9OL
         XsnejpGlwKFc3nz+z9brQ1fZaYH/JKmBK+jueenTXLYIBOez7qe7f8v+Db7b0LHhvgd6
         B7fA==
X-Google-Smtp-Source: APXvYqzFCjqlZU+HDCyGiBEvpK2/pADBDo3dD7v/H/FvucfCIeD6scQK7TlMDTLTVLBWsfhNeMf1fA==
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr14275839pjr.111.1564954845639;
        Sun, 04 Aug 2019 14:40:45 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 143sm123751024pgc.6.2019.08.04.14.40.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 14:40:44 -0700 (PDT)
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
Subject: [PATCH v6 0/3] mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Sun,  4 Aug 2019 14:40:39 -0700
Message-Id: <20190804214042.4564-1-jhubbard@nvidia.com>
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

Changes since v5:

* Patch #1: Fixed a bug that I introduced in v4:
  drivers/infiniband/sw/siw/siw_mem.c needs to refer to
  umem->page_chunk[i].plist, rather than umem->page_chunk[i].

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
 drivers/infiniband/sw/siw/siw_mem.c        |  19 +---
 include/linux/mm.h                         |   5 +-
 mm/gup.c                                   | 115 +++++++++------------
 net/xdp/xdp_umem.c                         |   9 +-
 9 files changed, 64 insertions(+), 122 deletions(-)

-- 
2.22.0


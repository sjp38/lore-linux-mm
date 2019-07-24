Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B26CC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D80C218D4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kd6PSC/U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D80C218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4A166B0003; Wed, 24 Jul 2019 00:45:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFB478E0005; Wed, 24 Jul 2019 00:45:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE92A8E0003; Wed, 24 Jul 2019 00:45:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8996C6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:45:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k9so23357071pls.13
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:45:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=a82RGTEXPGUxT9wrhIl0SGm+IUg23fG0znFClaoZF2M=;
        b=f2mVBCYsYokdFCh10oFWUmjoxUyNwr0c7cBX+1l6WV+nDvWmbRJ/3igfP4E5Dtul46
         2v9DYjDLhXpAVXZxgyfXP8sDwVmJI4VYkw5x0GItyco/dhOw3uBS6i/+WYkYcLNG/ZKW
         A5KU28OmQzmuvLPtce4cigpwQNPneIa9+IquxVRUUc+Ui57sQWotm/SFL/f+4CH9WEEY
         gHTuUTDQurU5Q7Y5yhnncYf4NQC5u0zoIFn9Net+EeuM8oK5VGLEGBBFr9hdxOoG8wi/
         QSsrAfvkoVWTYzXKVv5BidiAS6fRZ1UDK+wSOxoml0KlFNAUirx7zG/STwwEGn5RI2ja
         T+uA==
X-Gm-Message-State: APjAAAVAiNXf8PWxW534npyT2SDpNms9Bs5pC+mxAaZ6FKIMqbbYJI/6
	jt/ZsW4PI7gKJbnqsv10u4bmwtrXb5t3q1ZS0XX/vRql2m1N32bzdxN6mSwdqGENdKhFUKX2fxj
	2iUTL21K1MPTAbSi+YjbGZ777ELvaGWU0HJy18Xuzlq71jNe0MG7VWrOklRuPreaHeA==
X-Received: by 2002:a62:3445:: with SMTP id b66mr9336777pfa.246.1563943544212;
        Tue, 23 Jul 2019 21:45:44 -0700 (PDT)
X-Received: by 2002:a62:3445:: with SMTP id b66mr9336726pfa.246.1563943543458;
        Tue, 23 Jul 2019 21:45:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563943543; cv=none;
        d=google.com; s=arc-20160816;
        b=aUMbMmEqk5FbSfE6xU7NLwywDO6QK6A72jim1FdzlRoPbpLaafV86yhpDXDLy5uIzf
         0MHyqtLjdBWiP99qdbd7GUU1ZNpRZV80iB/t5Urk9sWN6+mvTL9Eqjo4UxxeWcrzEtpM
         KvFfplRjhiXvnQLQZd/4pbTTmckO2NcFZcrt+GmlGqhLjDx5ug4E5hKUbc7f8pu0Rb0w
         s1K0pY8qducitM6bhnkTQN7Gtk97x38C2ijq7M2OMIH8jhSlhDKYOI0Gx6Dap0RyVJa5
         iTPlgMzB04i6So1+d1yhd+qSXPHtvnJETz+mywhpXssF/EOtythYLMtRLFjG7uOOzdXj
         UdBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=a82RGTEXPGUxT9wrhIl0SGm+IUg23fG0znFClaoZF2M=;
        b=1ElA6ypTDn4tJWDr/wjVm6gBRUPDn3BDtC3sWKUKX9Y/BFrGv8wWQ0shpsuFkiXvdN
         XPFAtukD8vFVixSSw5hk2YtQlPHBUAi1OTVZpBGKolPYq2rBbnk3IZPht+MUo+suKAiC
         tqi6GJUCVErI0mqMn/OoRkxV7stm5fb/iHUDsrgzT3DyiVaJpF3fjf/Svr748U4GLEKV
         B1WlmBxV7gsCLrGIPFJvUyxjLO1bcOayAX2/RxKfVtxFuQFAl1+9i6qSPUjKHEpEOXS9
         sydIRpqEfADdNDeVD6Dd5l78VjlwtU/ezKZlbGgbi7wIT5COt2RCcINwp+UwVmFmJhWo
         /OvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Kd6PSC/U";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k65sor25187332pge.18.2019.07.23.21.45.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:45:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Kd6PSC/U";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=a82RGTEXPGUxT9wrhIl0SGm+IUg23fG0znFClaoZF2M=;
        b=Kd6PSC/URd7UIKcw58+fxXgQ892se8NpHm4OEg6NafKMnFMjvCAiIWdHCoPlLPqc8L
         aJ2qPkFGF7rV4DRVYtDw+kzTyKz++lpvKqFQcAl7iCYllE6k6lUQW6B8w5u+byvfT5Fa
         Q+WPYT0yXJJOYRou8VbShLD+Gu3cc60uHbegYi/Y7R4SDcQBKGF+uJ9+OtewKzKdHYa4
         mDkxAnsVFsH5foR59Pl19TCg37A2eC/JUZHs5kG/6JwxZW5fVI4ecC6e+3X2Ighkd2ts
         XemnURq3vKLirIn4/+d6ODT0qlTyYo8BgEmwVl9sISBYhC7Lqlq4LZICijaj0IvIIAaT
         a7IQ==
X-Google-Smtp-Source: APXvYqxX+DOW07WMhb+fJsFbx0LQzjFWgiNXaRMsjDo7bpqayKueY9DMdaxKoauo3MlhyMuoWNYR+w==
X-Received: by 2002:a63:1749:: with SMTP id 9mr27042805pgx.0.1563943543120;
        Tue, 23 Jul 2019 21:45:43 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id b30sm65685861pfr.117.2019.07.23.21.45.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:45:42 -0700 (PDT)
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
Subject: [PATCH v3 0/3] mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Tue, 23 Jul 2019 21:45:34 -0700
Message-Id: <20190724044537.10458-1-jhubbard@nvidia.com>
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

Hi,

I apologize for the extra emails (v2 was sent pretty recently), but I
didn't want to leave a known-broken version sitting out there, creating
problems.

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
 drivers/infiniband/hw/qib/qib_user_pages.c |   5 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c        |   8 +-
 include/linux/mm.h                         |   5 +-
 mm/gup.c                                   | 115 +++++++++------------
 net/xdp/xdp_umem.c                         |   9 +-
 9 files changed, 61 insertions(+), 106 deletions(-)

-- 
2.22.0


Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D44DFC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7904C20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hlrXri4C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7904C20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 003416B027C; Thu,  6 Jun 2019 14:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECDC96B027E; Thu,  6 Jun 2019 14:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBC156B027D; Thu,  6 Jun 2019 14:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC5706B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:44:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v58so2896129qta.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=Tcl38YCYPEHxtG59vS1/laf3LqY602AZ9Gwml32ANEI=;
        b=OiC75u2GkNp9Tydi1papY2tkl5BM1ui0ns2XUSh0YSUpNLGXeKZSJBPuhmjDCKu1+R
         XsCpLWfJFzX50942mMRISo/P1YXXyPgvp3rylv3nOM+q7/iwNIb43xnWOJWeRdn56v+f
         HsosN9/VUdDIis335Goahx9/gKkmBS8ZwHM6MxUG2aQ/tgq4MTcBWQHLf2Jzmx456asY
         skbo/NMBAFDj5jfdbekS7e99Topa5wCbEuZnPDF1bXWGLcACsChKmlO+qlSHbFhN3mi+
         rG3JaTDkaUmFddGJeNMhorxyAH6/h8pvb9iQxAiECurP8teQqOpLMnqtw1OS7+qEibS5
         Fm8w==
X-Gm-Message-State: APjAAAVQavCFG4zqhjE/dVcHCUG4WEM5NGWmZRdWT+taYBLZzNqL3Kee
	kTFpZKgjO2bKeKDM1f96xPE6Rka9NDPs1JW0ihBjkktUMW5dB4MxIeesJyxCkITlf7csh5u4D/q
	dXugUjN2h270e/EQ7M/eA61WDX8vjIQP90Iyy48jJYAFsSEaWS2DYJ+Uaarl0OuShUQ==
X-Received: by 2002:a37:4e8f:: with SMTP id c137mr3214745qkb.127.1559846687462;
        Thu, 06 Jun 2019 11:44:47 -0700 (PDT)
X-Received: by 2002:a37:4e8f:: with SMTP id c137mr3214700qkb.127.1559846686686;
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559846686; cv=none;
        d=google.com; s=arc-20160816;
        b=0GqCOuNjK2DyefXzDbaOmKl4yeHAMJk6nmQT/lzIYbxkknfK3FvQrgy0kLD+vq0koD
         JHTg/5IhMWyIGoxUApf8HElMI5S0adjtTjjrvqkXgxJIR9hccqgMPnRWCI0jYYjIkxVK
         9bsuUrZufBf1sByfeE3Thw1SrzcNJAz+TesaxN7zMFi9xqg71bvEIoeopJxNnu4G7ukQ
         odiFbVuviMN0f5dD5xkzyNa+83LKp8NgEyOe+twDbcuNS960NCRXUV2ZZVVlU96xvoq1
         sfVdgWJyXX4wv5CHomjtRLO7nU275VsHbaHmTJ/bvXQUmfLtOjjLwEeCwFZyKwIT3suG
         lRBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=Tcl38YCYPEHxtG59vS1/laf3LqY602AZ9Gwml32ANEI=;
        b=DfidKf3aoboqBnuwNdzaVUGcOHjzGNtsgB9WOJYABpMP1jQS1+ZMvtipQZ5Jhsev11
         SggifZdR/i/aFiVqSbg556wae3+vdmZBubAzws5jrTHuq7NNEivtqbKszc7qd2ZvWF9E
         FOna8jK32aM6bKbSvi63+UnFbV6H8X1roQJXTBAklXpZDoWOrc+tf6KbwSAuxfLnbj4S
         eM5Q9aSsRyBNCA2KuVvKieteRixP3GBd9+6D2o29XEDdum0OYyjdl54bnXEw1DGkuwej
         kpq8DBExWzgUslJDmxqGVzTYs+KyEG8q6mI4pa/Pwi+uHicB+PhxKJkMeb4hgEjqWVOA
         TiqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hlrXri4C;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor3109275qtk.65.2019.06.06.11.44.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hlrXri4C;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Tcl38YCYPEHxtG59vS1/laf3LqY602AZ9Gwml32ANEI=;
        b=hlrXri4CeEqiio7H/zfky6NMR7c65pBi/F8pbkmeJr2seEsfBd9qQbAyoCdHKPCuAC
         qOjGVsCwywsrQAs8F8f7bXbvI4mxQXMaLzXfL+nD0jx3Re+FpvedlkosN9s82eEcILOF
         jjkWSF5MrKwcYO1kxfxzkGpH5jfkehCo7dr1F9ZVwxWOtEG3YD724vwOMu83c6AsplFV
         wapKpAfXNKW3ibR5Yp3tsVpjC565fxndhwuL+Aw71vwHim7yGiO0p7XecLABBh9kjhYa
         RBziZbveeMFL4Dvyn731jLuoNH1SB7mJwtOsx5v/oKmqUFczBchHp49QeSTBXmd1v1Dv
         415Q==
X-Google-Smtp-Source: APXvYqwHsJyTk4fQz5PZYwBgzdqZtwH6jrE0uJFj5aHZhZ7tQwHTh6bgGfHk1coLRSMVlHO0bDCdZQ==
X-Received: by 2002:ac8:1a39:: with SMTP id v54mr42610485qtj.21.1559846686346;
        Thu, 06 Jun 2019 11:44:46 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c184sm1290839qkf.82.2019.06.06.11.44.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 11:44:45 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxNV-0008Hz-CZ; Thu, 06 Jun 2019 15:44:45 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com
Cc: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v2 hmm 00/11] Various revisions from a locking/code review
Date: Thu,  6 Jun 2019 15:44:27 -0300
Message-Id: <20190606184438.31646-1-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

For hmm.git:

This patch series arised out of discussions with Jerome when looking at the
ODP changes, particularly informed by use after free races we have already
found and fixed in the ODP code (thanks to syzkaller) working with mmu
notifiers, and the discussion with Ralph on how to resolve the lifetime model.

Overall this brings in a simplified locking scheme and easy to explain
lifetime model:

 If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
 is allocated memory.

 If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
 then the mmget must be obtained via mmget_not_zero().

Locking of mm->hmm is shifted to use the mmap_sem consistently for all
read/write and unlocked accesses are removed.

The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
standard mmget() locking to prevent the mm from being released. Many of the
debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
which is much clearer as to the lifetime intent.

The trailing patches are just some random cleanups I noticed when reviewing
this code.

This v2 incorporates alot of the good off list changes & feedback Jerome had,
and all the on-list comments too. However, now that we have the shared git I
have kept the one line change to nouveau_svm.c rather than the compat
funtions.

I believe we can resolve this merge in the DRM tree now and keep the core
mm/hmm.c clean. DRM maintainers, please correct me if I'm wrong.

It is on top of hmm.git, and I have a git tree of this series to ease testing
here:

https://github.com/jgunthorpe/linux/tree/hmm

There are still some open locking issues, as I think this remains unaddressed:

https://lore.kernel.org/linux-mm/20190527195829.GB18019@mellanox.com/

I'm looking for some more acks, reviews and tests so this can move ahead to
hmm.git.

Detailed notes on the v2 changes are in each patch. The big changes:
 - mmget is held so long as the range is registered
 - the last patch 'Remove confusing comment and logic from hmm_release' is new

Thanks everyone,
Jason

Jason Gunthorpe (11):
  mm/hmm: fix use after free with struct hmm in the mmu notifiers
  mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
  mm/hmm: Hold a mmgrab from hmm to mm
  mm/hmm: Simplify hmm_get_or_create and make it reliable
  mm/hmm: Remove duplicate condition test before wait_event_timeout
  mm/hmm: Hold on to the mmget for the lifetime of the range
  mm/hmm: Use lockdep instead of comments
  mm/hmm: Remove racy protection against double-unregistration
  mm/hmm: Poison hmm_range during unregister
  mm/hmm: Do not use list*_rcu() for hmm->ranges
  mm/hmm: Remove confusing comment and logic from hmm_release

 drivers/gpu/drm/nouveau/nouveau_svm.c |   2 +-
 include/linux/hmm.h                   |  49 +------
 kernel/fork.c                         |   1 -
 mm/hmm.c                              | 204 ++++++++++----------------
 4 files changed, 87 insertions(+), 169 deletions(-)

-- 
2.21.0


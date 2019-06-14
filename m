Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2133C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F81C2173C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:44:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lwkJgPlj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F81C2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE5D16B000D; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBBF36B000E; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0F556B026A; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFD856B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:44:55 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n190so659587qkd.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=R/AhTlxkz9VD/Gth3t6L3luS1MUasGphGhAFUOpm608=;
        b=CYFJrixElcxgWFsk1/FGxl/75B1cLHeUZA5i2tsjAUKb0I9CA1X0K8fzpWH1uGvQUt
         ezN5tZSL/Shlo315vekn9bvjCeW5ebgZP+5v/6ifUXi3sZ7gHAOM7irmhcZ+/GcfzJnB
         iWACf13BgevJnVR5fVNApIh6jRBB/Wze7viDAXnySt+VIhxwWkSBVXobKJgyMMbzlGy7
         /2shcOga9uJI5CYTYsY3fKpCr1NBEy7Jqej07d+RrrgXC2TL1148jBru9xYdqsqCJ/dZ
         A4s5hOvGB3HV+oy5K/S4OuWrr/pVh9Mxwz3A8yLxbqMuA5KD+TgmS+pAv9VVLIJ96htr
         +uNQ==
X-Gm-Message-State: APjAAAVfE5QvkuJ/NzZ1Zxu1/hoBwgfFg/jfJW/BReLzo9SBbaS+eIF7
	uIe/54oX644+zzjtn3vNFOc2Ty30KMuIxIRVF5XF+8EQb4Wa87UaqaKA2FIlRlQnx1Xqq9wf+Af
	Fv/EeS+mhsDelw+fGRgTvUEGr4RRmCciAO3Dp/T1HNDhOLzXImuSY9MaB4H5xGvdpdg==
X-Received: by 2002:a0c:9151:: with SMTP id q75mr5972517qvq.168.1560473095428;
        Thu, 13 Jun 2019 17:44:55 -0700 (PDT)
X-Received: by 2002:a0c:9151:: with SMTP id q75mr5972493qvq.168.1560473094770;
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473094; cv=none;
        d=google.com; s=arc-20160816;
        b=vIjHKtrkFc2f4g3GWKzwBShnoDj5SgjsQWNJl2N6RFVqumtdTwbr6b6TqU3uv0tLRK
         SxvIgnS6dmcqCNaTCAVQux5jWigl7DXPG8NaLwK1hhIfaDmsGviB/cynSy1rRWXg1BCD
         Yis7X4dmp10NKD1dD5tW6n5etXsJyboTA0Ds/4FsdyZFuvnequz16LhiLSKYY3vhXhaw
         JH3/jSvm5Fm45AAzNpJLiqOApLog/yZRKfZz2DwFmqVD9e+q6wX4MUbsDWDEJUETtAPG
         3fOMt8UcCuIdvPNAhan58KbasJej6nRNd12XtfQ+BHco2DygPWjwDjdnwTBmbFGZP3kZ
         NpuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=R/AhTlxkz9VD/Gth3t6L3luS1MUasGphGhAFUOpm608=;
        b=EKef6525fNIDA31ZJqWMo8zS0HrIoMdvSVxAC35b9t0y2qjX1BgwcpqyCR9GUF+TSc
         wG0Be4TMSv09OQ79z10iK4J1ndLXOOO+YuDJCEkZUMsbyekAm5mF+8iFDfhUqXwL8Oe2
         QOHVgqbYKt3GgNhsGyqXyS+zZEnluCuSasNrqI0+ap3CtWZpFgUW6TKdxxrFDxKYCF8a
         sA+Dya0q4AjgFP/7Uhj0Xefd+kKY1B8aysB1N4n9M5zO+oMN0W2YSfTxLVxydSfL6saZ
         EX0dBIkkyBtFoZyqKf7SChjZeRBd8xXPBz5iBHBGcu3AuBP7KIMxQEhO4hoHlRHgC1VG
         NpkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lwkJgPlj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j28sor2340106qta.53.2019.06.13.17.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lwkJgPlj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=R/AhTlxkz9VD/Gth3t6L3luS1MUasGphGhAFUOpm608=;
        b=lwkJgPljFC3Tn+LXK7qjmyhVvethI42H5ylf1MGRcm6oKxXVhq8Wzl8TRDe9Eqm+YN
         rJkB0pghRseSkcWlc54ohBbckUGirR4baXgc8115jYObInJrRLwQtP1X+52KdX8JiSYG
         ZULIP8XcgCXVOf6rHO/PNjB1SdPHt7h/hl6bwATGZ4PjbayxrcZKj0MW25KMUNfW8oby
         AUpBHYJLOgSKHGgD0ip9zurdr2qqnIm8rtMl4gsk1TRGtmQsYhUxbnXWYhvO49MrsJaQ
         CyFu2i3cjrPLnh9c7W2+KHMZZ1HkvmrdKx7z9NMxZ/34RA3NYsFe25qalY3RhhfJ8whk
         95HQ==
X-Google-Smtp-Source: APXvYqwwLhCAHZe6HhzxmL/Iw5P6iX8RWN7iT/fwDDndsKBg+CvZVk5Nt+VA+fnelddHK4pmtIZtkw==
X-Received: by 2002:aed:3ed5:: with SMTP id o21mr76020282qtf.369.1560473094348;
        Thu, 13 Jun 2019 17:44:54 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c55sm754749qtk.53.2019.06.13.17.44.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 17:44:53 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbaKr-0005JR-I5; Thu, 13 Jun 2019 21:44:53 -0300
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
	Ben Skeggs <bskeggs@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v3 hmm 00/12] mm/hmm: Various revisions from a locking/code review
Date: Thu, 13 Jun 2019 21:44:38 -0300
Message-Id: <20190614004450.20252-1-jgg@ziepe.ca>
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

The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
standard mmget() locking to prevent the mm from being released. Many of the
debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
which is much clearer as to the lifetime intent.

The trailing patches are just some random cleanups I noticed when reviewing
this code.

I would like to run some testing with the ODP patch, but haven't
yet. Otherwise I think this is reviewed enough, and if there is nothing more
say I hope to apply it next week.

I plan to continue to work on the idea with CH to move more of this mirror
code into mmu notifiers and other places, but this will take some time and
research.

Thanks to everyone who took time to look at this!

Jason Gunthorpe (12):
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
  mm/hmm: Fix error flows in hmm_invalidate_range_start

 drivers/gpu/drm/nouveau/nouveau_svm.c |   2 +-
 include/linux/hmm.h                   |  52 +----
 kernel/fork.c                         |   1 -
 mm/hmm.c                              | 286 ++++++++++++--------------
 4 files changed, 140 insertions(+), 201 deletions(-)

-- 
2.21.0


Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DFBEC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6B7121773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:34:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="I9LiNRnS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6B7121773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4E66B0272; Thu, 23 May 2019 11:34:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574E26B0274; Thu, 23 May 2019 11:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 462B26B0275; Thu, 23 May 2019 11:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26AF76B0272
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:40 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id m15so5692107qtc.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=LEV5tWURKgLpgo5q6BTc4NlcwzQLAQ+EC5rW0mqA8Xo=;
        b=hPgk0xkozyKv6j2I0fekHeudCiCvA3bPinh1DUebGr/SmZsih8k+6sWcH8hknCeDWu
         5zHB61Z49X4o8P5RfDFzz0emL+eg30a3Zlu0itLiwlG4b+3qSaKwPCqGdO2RGuqzwzEw
         T9xnglrfG+DsRCNid5xKVTo34ER53CJL9Y9c9wlxIA8Mlj8kkj3dfK71RpNJyKDyq8/8
         Gpzlz+A3g36ZH8WbvElxB3SkDX5cvqOqfA+uAmWbGxihvvJDA/qqC/GPbmYSRYh2e3jY
         0oKjyfsvfbDpqs/8WtqXMvPh8S1e5PtOa4svEpk1t1mhWVFnwczkjp99MLZq6UbfMZgX
         0T4A==
X-Gm-Message-State: APjAAAVpN6uyrXonDDuHsvIIX7CLNy1P+PBoN9PDxhud+BrDDN0GS2HQ
	xqbkb4rf5kg9AkWE+r6B387rzhjzzTkkHiCSZO2pVzIzROdz9cMq+QuAdTNV4DMBgvgjXZUzPvI
	aPAN52QPdeGSg7gbGga1PhQ6AV3IHkqUEI9RjvMwpS2hvAZNEiXnfm/p9kjuu/AvFTA==
X-Received: by 2002:a37:dc03:: with SMTP id v3mr77026216qki.151.1558625679929;
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
X-Received: by 2002:a37:dc03:: with SMTP id v3mr77026154qki.151.1558625679188;
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625679; cv=none;
        d=google.com; s=arc-20160816;
        b=SmHLCdgDfoqxfXrVkemV6Km2SKNGLbl93c1xz4fdDAtXg2tphxEtW/872ZPzPiJaQP
         mN5Vdyf7FIo6fhDvuYk30ADz/L/7ORZzrLFRklTn3AIqnaZKxsck0yT7plbi50FHp7SD
         aMoootRzDpwn71McBp9Zg3wQAqEm2eDQeHRyAoJIijouD21RymzQy4cMb6Z0PXxVFKx0
         7RvGqHGjUE9kfZRAGSVky7CnVE1g3asaCwfr2zxKH/mbN2fscjuqrTsUONC2OkTuFOP3
         0xkJmLPdtseboSX62B7c/+o3hngOBQrprfOLD5SbiaI5iaFXJ9Gph1WJ0hrbBUZEIuB0
         61PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=LEV5tWURKgLpgo5q6BTc4NlcwzQLAQ+EC5rW0mqA8Xo=;
        b=wb+XZ1AtUz9DqiKP6jAC4qiuIA7arzvjX31DvwQz+JTlTU8zpNbmafwoSUzMbcIln5
         hioJT1S1zHBQHOlrdJlx6dJQT40hlUGZSLh+WKzP13H/RNIMhUWU/3+2ovKzOo9jk5H3
         MunNU8zrsd8+0CiYZmIuLLVvIpKcdBHZ7/U5IvlKOiQ6LTGkwrNW2KPaKO98D2ZMjyjA
         TNfNE0e9MEa0d4+3d8Wra3sP2M3Jktdg6BUWzuYt+9R1U3hISXuI4zNqN0xceoiOu/is
         Rx95qvQMsQuusekV22B3t4jYK/ex8yQP2Zf2xooDOuPBzDnsCp9zknSkGr1uhy6TN0CS
         3M8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=I9LiNRnS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 25sor21546407qvv.34.2019.05.23.08.34.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=I9LiNRnS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=LEV5tWURKgLpgo5q6BTc4NlcwzQLAQ+EC5rW0mqA8Xo=;
        b=I9LiNRnSFZ2kQk44SojHBUW2L/OelCgKL7qFGsT/eFBZ2o/2dPwYCQGKf+9I82gF9J
         YmMPy0Vt8yxMxwVrRjPf1tzl99wZpY7NcFdn6A/F9DXWGGsgYFAf9hzxBTZhnRj7FpkX
         KCfPvI3xXOWOfHmUYKlJnS7RLRigNiJ4KB6Y4eR6rbyCee8r5pMw+2ivxFrA4Ayu8Gss
         PQfscnAUj4S9o3GZGzlKdoR9TJ5mZQ9/q38CVQfZDT6a0bWJ/CMpI9Ri3YdsezPFWpTT
         TGOExwxE+rRG5Ddo9+islZJbknQywxmTIzteFK17fpDdnRWg0EIaptARbwqBp/Gn1e0a
         KLeQ==
X-Google-Smtp-Source: APXvYqyiewADpQP8cIsdPqhAjkY2KNXOElH4d5PbPs8KXkM0UEqnBsU2GR+WRo/ynGz4+mLf+I4aIA==
X-Received: by 2002:a0c:961a:: with SMTP id 26mr61952699qvx.131.1558625678799;
        Thu, 23 May 2019 08:34:38 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id o6sm14126879qtc.47.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:38 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjp-0004z4-RS; Thu, 23 May 2019 12:34:37 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code review
Date: Thu, 23 May 2019 12:34:25 -0300
Message-Id: <20190523153436.19102-1-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
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

Locking of mm->hmm is shifted to use the mmap_sem consistently for all
read/write and unlocked accesses are removed.

The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
standard mmget() locking to prevent the mm from being released. Many of the
debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
which is much clearer as to the lifetime intent.

The trailing patches are just some random cleanups I noticed when reviewing
this code.

I expect Jerome & Ralph will have some design notes so this is just RFC, and
it still needs a matching edit to nouveau. It is only compile tested.

Regards,
Jason

Jason Gunthorpe (11):
  mm/hmm: Fix use after free with struct hmm in the mmu notifiers
  mm/hmm: Use hmm_mirror not mm as an argument for hmm_register_range
  mm/hmm: Hold a mmgrab from hmm to mm
  mm/hmm: Simplify hmm_get_or_create and make it reliable
  mm/hmm: Improve locking around hmm->dead
  mm/hmm: Remove duplicate condition test before wait_event_timeout
  mm/hmm: Delete hmm_mirror_mm_is_alive()
  mm/hmm: Use lockdep instead of comments
  mm/hmm: Remove racy protection against double-unregistration
  mm/hmm: Poison hmm_range during unregister
  mm/hmm: Do not use list*_rcu() for hmm->ranges

 include/linux/hmm.h |  50 ++----------
 kernel/fork.c       |   1 -
 mm/hmm.c            | 184 +++++++++++++++++++-------------------------
 3 files changed, 88 insertions(+), 147 deletions(-)

-- 
2.21.0


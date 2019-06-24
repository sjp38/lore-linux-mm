Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D778C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22ACE20656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:02:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="RTldUZCA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22ACE20656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A09DF8E0008; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E4838E0007; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722E18E0008; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0743A8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:02:07 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id g13so1721021wrb.3
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=+TXg+V1PV7qytX0xwqixrcBsIlYVASLMn0QfVVkViw4=;
        b=bzGww4cYGTWQk8apUJnULx0mvEOgE0/g1hrcOGCky80p9sZlIEos/BF4/5qVCnENfL
         LSkhlqD6N6ikLaedp7gmjxrsEC02VuSVCBp4hcgt3oP7NiqNCZFGDgIHuoKe6Py85KLP
         vCb7+EwhUFtNuEM7hC3Jp11HvGsDvTj0zkRB0m8lkPFLUBKoye3ClAnUPPiABAjksPLM
         x4n9O9GLpjlU4PCdQU8oGDq5/Rl7+34+UK6WmgLdnujwI1MxFqC+Np2kg/paqG+LrYlq
         IQf7A80XZ9/GYXFrm9cgr6Iud+fpMf06ooEZSF+uyNNnl0vuvsIs6i01Jtk4mgaIGMfr
         27ug==
X-Gm-Message-State: APjAAAWWP4Tup393R5fBN92+nsL/VbcensftgUzN2GVgNb9pS5UPWzaf
	8fMtHylaMDFJAyEXTHleLtZ0DavVIbQnxFwHl2/5ODyiYDcYmsmnP4jw55H3vpXeJcdsZJt94Ql
	UU1h0GZoyfSrJnvpnKO3k+QRI855Hm6Kd7Oc/a8GlxUIljocRCvIQqPU7fER1kki3NA==
X-Received: by 2002:adf:efc5:: with SMTP id i5mr101872415wrp.158.1561410126543;
        Mon, 24 Jun 2019 14:02:06 -0700 (PDT)
X-Received: by 2002:adf:efc5:: with SMTP id i5mr101872387wrp.158.1561410125705;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561410125; cv=none;
        d=google.com; s=arc-20160816;
        b=zlrDkox8pV9Q+L7xLXQ0aNEiuPFiCsIVaxluvNOgn//11NQDm75ouvkzRJpredL7Te
         STaahn6l/WnpFEpTUx+1nsDPxKOER/HUglok/SP1taJsKbP2C55hy/YyYv1mxI5TLrVT
         xJTRNHp9BZ2HByTtND2PACXLmx9lzPSfJB5BxAUtb/DRN4dBZRVm9gaL9l60CQmNQpew
         Pv7yaesojnn2RUu1wLQgKl1iDbdLi/psoIFidfUhwcLxnLPdEhjzo5Wp4yUgCZyWG6Oi
         ry+luW0ugE5TR4gfonkbhzyjEnVgCYBuRUo+4jEKljcOyYSYGtiz0Ao2YFM8t/1o9owZ
         AQLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=+TXg+V1PV7qytX0xwqixrcBsIlYVASLMn0QfVVkViw4=;
        b=cj3AqwV8jb58U4lb6GDy2pWZyUCm6bjMKkc74LAYrhfn9XlATWgFZsbTFUZuFZSvpy
         0vLdY60lr3v0mQqR3T7njie/XQgpfEBANK61/SjQ/HS+xjOK6qsiwOjLNbePyeMuzzOX
         GvHjaCfzL5/xAer0fidvQdRjIXKl6go+6u5P42q2ja5qkv+aHOPOay4jclpe591TiuXe
         +aVeRoBJjS4Ft90g/5iaVmPbDn4TuzN55sRdclOD+19qgzyMDuAm+3HcQTyrHXgU0Qvu
         MZ55lBx1TkvQG8MiW+5K6TWk81iRoQToj1GGyh+nvJlrGsT6pl3BdhKNzYPaGpVmmX+M
         riDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=RTldUZCA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g66sor350776wmg.26.2019.06.24.14.02.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=RTldUZCA;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=+TXg+V1PV7qytX0xwqixrcBsIlYVASLMn0QfVVkViw4=;
        b=RTldUZCA/ujlOPqeFpIG1/oq7I0MMWuhfuWJToHG67t3OQXfVVzK17LY3kJ6F+Brer
         lnz/th7nTkxS/2R+LqhfZEwU5MvrsZIu821B9utLccmxMdrak8HYApdsHFF6X5Hm9BeZ
         Vo8kf7gnh3yt+gibgQeVYXuNFbbhYpUZLvfs+XYPYbnhZ2hu/dNSj1xBfyMpQjtX1doH
         EZDWsi96WfqzpwW/fpPX43H1AiRarnXcaSLJUUvqCyT81nbN45aacsBUof6bL1BIOqTB
         ajwQSV/zBBYiXqc83fyuqH5/tTOsWhrpi8aDboRkZhx14nYt1qY3C4UY4GvtasO88w1a
         gS5g==
X-Google-Smtp-Source: APXvYqzG1w8w/MlwN4mNnTDNK32BkM+Kopo5HpXOnXXh6GBim1Uqm95bmEpjBPM4rzRFOIIj8zgSlQ==
X-Received: by 2002:a7b:cc93:: with SMTP id p19mr16950467wma.12.1561410125331;
        Mon, 24 Jun 2019 14:02:05 -0700 (PDT)
Received: from ziepe.ca ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id l124sm464451wmf.36.2019.06.24.14.02.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 14:02:02 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hfW6C-0001Lx-Mk; Mon, 24 Jun 2019 18:02:00 -0300
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
	Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH v4 hmm 00/12] 
Date: Mon, 24 Jun 2019 18:00:58 -0300
Message-Id: <20190624210110.5098-1-jgg@ziepe.ca>
X-Mailer: git-send-email 2.22.0
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

The use of unlocked reads on 'hmm->dead' are also eliminated in favour of
using standard mmget() locking to prevent the mm from being released. Many of
the debugging checks of !range->hmm and !hmm->mm are dropped in favour of
poison - which is much clearer as to the lifetime intent.

The trailing patches are just some random cleanups I noticed when reviewing
this code.

I'll apply this in the next few days - the only patch that doesn't have enough
Reviewed-bys is 'mm/hmm: Remove confusing comment and logic from hmm_release',
which had alot of questions, I still think it is good. If people really don't
like it I'll drop it.

Thanks to everyone who took time to look at this!

Jason Gunthorpe (12):
  mm/hmm: fix use after free with struct hmm in the mmu notifiers
  mm/hmm: Use hmm_mirror not mm as an argument for hmm_range_register
  mm/hmm: Hold a mmgrab from hmm to mm
  mm/hmm: Simplify hmm_get_or_create and make it reliable
  mm/hmm: Remove duplicate condition test before wait_event_timeout
  mm/hmm: Do not use list*_rcu() for hmm->ranges
  mm/hmm: Hold on to the mmget for the lifetime of the range
  mm/hmm: Use lockdep instead of comments
  mm/hmm: Remove racy protection against double-unregistration
  mm/hmm: Poison hmm_range during unregister
  mm/hmm: Remove confusing comment and logic from hmm_release
  mm/hmm: Fix error flows in hmm_invalidate_range_start

 drivers/gpu/drm/nouveau/nouveau_svm.c |   2 +-
 include/linux/hmm.h                   |  52 +----
 kernel/fork.c                         |   1 -
 mm/hmm.c                              | 275 ++++++++++++--------------
 4 files changed, 130 insertions(+), 200 deletions(-)

-- 
2.22.0


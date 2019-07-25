Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F00C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 394F52064A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="QX20Wp3w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 394F52064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4AB58E0032; Thu, 25 Jul 2019 01:55:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFB978E0031; Thu, 25 Jul 2019 01:55:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEA568E0032; Thu, 25 Jul 2019 01:55:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC228E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:55:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so30158200pfb.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:55:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=e1xfsz0ZoNGxWjOEVlpLO8+aT1x4jFathNoxDpZIVqk=;
        b=ayr3ocdAuSehcW8qwvqwYHM/gYfLfz651f0jIbDVkoITQBkuMTLxNSKkSSG1aFrKBz
         9UxzWwxwnwi/exS2JxAsy+Jdy4bBaH+eUlMsm9ga4W+H+IsnFq6z1DB11+EcHIDnG5pB
         q+m5Ipk+IHZshqRP8k7va20PdtZhFP7HFl1tqQiYRhp7Wqem2BVq7GODmeDLhuKhLbF/
         mohlsC3R72Jcf6ZlDu8ceSoIO/O5jfnjBvF3a7/lSF/g80cRnclkmioJsdXc0Xcb2iwh
         U2p/pZD+YCYuGtG98HAVQyWMPUvOqOFyhVVr68yOU/ASU++jCKI73YZqf2dP6Z4K75Yr
         F+CQ==
X-Gm-Message-State: APjAAAWB8l4jhO/O87nZ5VXCcS2OpklYGOY5yK1/eUw2gszvks7Oj+yf
	yeQSPE1OSHECYPrnpWgtyxCv1jroTtEp6sAqCWsZyFINDzNK8fc76iVFgzxtLRFYUmD/RMPPzvy
	efevt6m3k/9z7Fh8ASAo6Gqs3uu5HEaHZAp/+V+9E0fd5TCqbB8lNtfJIYgh87KswCA==
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr14728048pfn.55.1564034116219;
        Wed, 24 Jul 2019 22:55:16 -0700 (PDT)
X-Received: by 2002:aa7:83ce:: with SMTP id j14mr14728016pfn.55.1564034115403;
        Wed, 24 Jul 2019 22:55:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034115; cv=none;
        d=google.com; s=arc-20160816;
        b=0dtUjjK9y6Ir8+fH8SNSB9vwKxKgBzoY881GAePfqa5wm0XMgHvNPmrXYraCvzw7I/
         ChI58y/5Fcpbd7hiW9OswANPt01GslrzyHYkdR0riAGWqcYSnvc8XV1flSDun3X72yky
         Q13ddurp62m+U3BbndggE2ZKwYDny4KMK24uOwfJ5WUzioAJzFzr2iHIxZ79UksAOhuI
         spaxKSDmqTY6ZrFFlVuGIYqLNj31MBXozX3afiPGei9jAV3FbbkAzUR5SFITF6vWkK1h
         7kuxIXLEM5fq3+WLMSWeqA6bSs0lwsyc6eaZc6ld9U/iZiqRsCSRXF4gk9ghWD7zdlN/
         2RdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=e1xfsz0ZoNGxWjOEVlpLO8+aT1x4jFathNoxDpZIVqk=;
        b=ltd4CLBECr7YUGYCmi+jM4/LlFF1OBcEaW2s/NUgnCXVBWoIokSFK6zRaeGRHjw+Ih
         KnE81yu9i3E5AIeJ2jyW6VaZPjDpQBzHrLoNh+Klp2nGtxGQI2RfzNqQZ7rB1xz0qNjX
         w0UTH7dbpru0LprNMS/Xfuew6qfTH0AeZGRWsv9AT3vzJqgtn9tT5qndK4ZWOjmxerhm
         hykiZdRlqb9Okzn9bhzFoK2PSQLs+HUVRkaWvAnEpKE924siHUPlRoQ2CNbxNW9foSuw
         mPJdDrVhP7E2C06dY7tvsPb8EdKO9vp9tOgVtUzk2aMR4reV5rZl+/I5iYl3lNNaGECj
         zj9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=QX20Wp3w;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6sor8336047pgt.14.2019.07.24.22.55.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 22:55:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=QX20Wp3w;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=e1xfsz0ZoNGxWjOEVlpLO8+aT1x4jFathNoxDpZIVqk=;
        b=QX20Wp3wlNJVGmKQ0Nwg1sA4qyOePQwhgRGQ/b+yPexX9TsVq/Q24UOBUqfMJQtj8/
         +11w7SZpH/Inq5wl3WQno+etqhZmLTfls8CfKJlumQJhMIfJ/nBGainljr0U4YVnlPhE
         OeKeM95dlLTh8uAe67RoME6q2ZoCXeHFdfiyg=
X-Google-Smtp-Source: APXvYqwNQbWJY1nHcn4OQbGLwt8IYJCFlsYg04P0YNd9LNS8ShorPFklIYUwXA6Lq/AeBMREvGvCcA==
X-Received: by 2002:a63:c008:: with SMTP id h8mr82471776pgg.427.1564034114982;
        Wed, 24 Jul 2019 22:55:14 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id a3sm51027777pfi.63.2019.07.24.22.55.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 22:55:14 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	dvyukov@google.com
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH 0/3] kasan: support backing vmalloc space with real shadow memory
Date: Thu, 25 Jul 2019 15:55:00 +1000
Message-Id: <20190725055503.19507-1-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, vmalloc space is backed by the early shadow page. This
means that kasan is incompatible with VMAP_STACK, and it also provides
a hurdle for architectures that do not have a dedicated module space
(like powerpc64).

This series provides a mechanism to back vmalloc space with real,
dynamically allocated memory. I have only wired up x86, because that's
the only currently supported arch I can work with easily, but it's
very easy to wire up other architectures.

This has been discussed before in the context of VMAP_STACK:
 - https://bugzilla.kernel.org/show_bug.cgi?id=202009
 - https://lkml.org/lkml/2018/7/22/198

In terms of implementation details:

Most mappings in vmalloc space are small, requiring less than a full
page of shadow space. Allocating a full shadow page per mapping would
therefore be wasteful. Furthermore, to ensure that different mappings
use different shadow pages, mappings would have to be aligned to
KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.

Instead, share backing space across multiple mappings. Allocate
a backing page the first time a mapping in vmalloc space uses a
particular page of the shadow region. Keep this page around
regardless of whether the mapping is later freed - in the mean time
the page could have become shared by another vmalloc mapping.

This can in theory lead to unbounded memory growth, but the vmalloc
allocator is pretty good at reusing addresses, so the practical memory
usage appears to grow at first but then stay fairly stable.

If we run into practical memory exhaustion issues, I'm happy to
consider hooking into the book-keeping that vmap does, but I am not
convinced that it will be an issue.

Daniel Axtens (3):
  kasan: support backing vmalloc space with real shadow memory
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC

 Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++++++
 arch/Kconfig                      |  9 ++---
 arch/x86/Kconfig                  |  1 +
 arch/x86/mm/fault.c               | 13 +++++++
 arch/x86/mm/kasan_init_64.c       | 10 ++++++
 include/linux/kasan.h             | 16 +++++++++
 kernel/fork.c                     |  4 +++
 lib/Kconfig.kasan                 | 16 +++++++++
 lib/test_kasan.c                  | 26 ++++++++++++++
 mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |  3 ++
 mm/kasan/kasan.h                  |  1 +
 mm/vmalloc.c                      | 15 +++++++-
 13 files changed, 220 insertions(+), 5 deletions(-)

-- 
2.20.1


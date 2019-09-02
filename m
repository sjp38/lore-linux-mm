Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DD48C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42332217F4
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 11:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="Rhhm4VfH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42332217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE55D6B0003; Mon,  2 Sep 2019 07:21:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95FB6B0006; Mon,  2 Sep 2019 07:21:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAC3C6B0007; Mon,  2 Sep 2019 07:21:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0043.hostedemail.com [216.40.44.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2AA6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:21:21 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4E08A6122
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:21 +0000 (UTC)
X-FDA: 75889739562.03.jeans78_28d740640ed53
X-HE-Tag: jeans78_28d740640ed53
X-Filterd-Recvd-Size: 6511
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 11:21:20 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id d10so2783268pgo.5
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 04:21:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=73TlGEwK6oKiZ/rkmArAnsPJNae2N4hkEOloXefysjM=;
        b=Rhhm4VfHtnyt2JvxlWHInpQFUnr4IjDvHWve41dxBUjTRnX5YIUfmoLpYdhbRpEJ96
         zotNlyxp8TbUzVMrvwyf5jDhkEgrcZpw2iXUuuh78i2YhYA59nQowTqs9xosiwspC3w0
         nBWXVcjWjD3udTsye61lFsb+3l/t2DzQkiMKM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=73TlGEwK6oKiZ/rkmArAnsPJNae2N4hkEOloXefysjM=;
        b=Vi8wk0YXp2LxtPOyHubZvumi2K+BS8EOhzsRny2sHVaRDYmR2hFBVqfpNK91SBZtAd
         7jojiunasyJGorxQNE8gQiQgW04A8Mzs0Uxxr1ZQa3QliqPZ8Oy/UoW1s3tjwCO79G4Q
         7I1qh1o/WzK8g0lPQxf+RCu1tK/S3mgGrekd/pIsvMWmGTvpIWPnQOKVXK8l1I7+Emx8
         UZ6LLVOAg81EFaDssyx2el8sbYtePrvVjRjnELFDoS92LaTkkPhiHz54EHAm4d/cWLwU
         YqGsGnfMm26txqh9xNfksrH9/vnPb+rw4NVP1nRSo4N7AcneEzyjEZZQIfVtTDoLiJa3
         sTTg==
X-Gm-Message-State: APjAAAXqmfOFs/ZbLTDGq06Cpf/Dv5nq6D+S4bP5VQtS8CR9QqGVZ46g
	rOmM6p+UoGBgYgHO9ZFJEuDNbw==
X-Google-Smtp-Source: APXvYqyyJrIGNF/49jX946xepT3hLe7HM0PDMzFhBMdhjz56mjhnOrOqjg9qT8NraW9rYZyehdy5AA==
X-Received: by 2002:a62:80cb:: with SMTP id j194mr34723282pfd.183.1567423279444;
        Mon, 02 Sep 2019 04:21:19 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id x12sm1054597pff.49.2019.09.02.04.21.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Sep 2019 04:21:18 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com,
	christophe.leroy@c-s.fr
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v6 0/5] kasan: support backing vmalloc space with real shadow memory
Date: Mon,  2 Sep 2019 21:20:23 +1000
Message-Id: <20190902112028.23773-1-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, vmalloc space is backed by the early shadow page. This
means that kasan is incompatible with VMAP_STACK.

This series provides a mechanism to back vmalloc space with real,
dynamically allocated memory. I have only wired up x86, because that's
the only currently supported arch I can work with easily, but it's
very easy to wire up other architectures, and it appears that there is
some work-in-progress code to do this on arm64 and s390.

This has been discussed before in the context of VMAP_STACK:
 - https://bugzilla.kernel.org/show_bug.cgi?id=3D202009
 - https://lkml.org/lkml/2018/7/22/198
 - https://lkml.org/lkml/2019/7/19/822

In terms of implementation details:

Most mappings in vmalloc space are small, requiring less than a full
page of shadow space. Allocating a full shadow page per mapping would
therefore be wasteful. Furthermore, to ensure that different mappings
use different shadow pages, mappings would have to be aligned to
KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.

Instead, share backing space across multiple mappings. Allocate a
backing page when a mapping in vmalloc space uses a particular page of
the shadow region. This page can be shared by other vmalloc mappings
later on.

We hook in to the vmap infrastructure to lazily clean up unused shadow
memory.


v1: https://lore.kernel.org/linux-mm/20190725055503.19507-1-dja@axtens.ne=
t/
v2: https://lore.kernel.org/linux-mm/20190729142108.23343-1-dja@axtens.ne=
t/
 Address review comments:
 - Patch 1: use kasan_unpoison_shadow's built-in handling of
            ranges that do not align to a full shadow byte
 - Patch 3: prepopulate pgds rather than faulting things in
v3: https://lore.kernel.org/linux-mm/20190731071550.31814-1-dja@axtens.ne=
t/
 Address comments from Mark Rutland:
 - kasan_populate_vmalloc is a better name
 - handle concurrency correctly
 - various nits and cleanups
 - relax module alignment in KASAN_VMALLOC case
v4: https://lore.kernel.org/linux-mm/20190815001636.12235-1-dja@axtens.ne=
t/
 Changes to patch 1 only:
 - Integrate Mark's rework, thanks Mark!
 - handle the case where kasan_populate_shadow might fail
 - poision shadow on free, allowing the alloc path to just
     unpoision memory that it uses
v5: https://lore.kernel.org/linux-mm/20190830003821.10737-1-dja@axtens.ne=
t/
 Address comments from Christophe Leroy:
 - Fix some issues with my descriptions in commit messages and docs
 - Dynamically free unused shadow pages by hooking into the vmap book-kee=
ping
 - Split out the test into a separate patch
 - Optional patch to track the number of pages allocated
 - minor checkpatch cleanups
v6: Properly guard freeing pages in patch 1, drop debugging code.

Daniel Axtens (5):
  kasan: support backing vmalloc space with real shadow memory
  kasan: add test for vmalloc
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC
  kasan debug: track pages allocated for vmalloc shadow

 Documentation/dev-tools/kasan.rst |  63 ++++++++++++
 arch/Kconfig                      |   9 +-
 arch/x86/Kconfig                  |   1 +
 arch/x86/mm/kasan_init_64.c       |  60 +++++++++++
 include/linux/kasan.h             |  31 ++++++
 include/linux/moduleloader.h      |   2 +-
 include/linux/vmalloc.h           |  12 +++
 kernel/fork.c                     |   4 +
 lib/Kconfig.kasan                 |  16 +++
 lib/test_kasan.c                  |  26 +++++
 mm/kasan/common.c                 | 165 ++++++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |   3 +
 mm/kasan/kasan.h                  |   1 +
 mm/vmalloc.c                      |  45 +++++++-
 14 files changed, 432 insertions(+), 6 deletions(-)

--=20
2.20.1



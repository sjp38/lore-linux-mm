Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D107EC41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 862372067D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:16:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="bkxZ5igs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 862372067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26F4A6B0003; Wed, 14 Aug 2019 20:16:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2209A6B0005; Wed, 14 Aug 2019 20:16:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E7906B0007; Wed, 14 Aug 2019 20:16:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id DC87C6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:16:55 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 95A1740E6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:16:55 +0000 (UTC)
X-FDA: 75822746790.22.joke64_1f4d680c33c3f
X-HE-Tag: joke64_1f4d680c33c3f
X-Filterd-Recvd-Size: 6317
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:16:54 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id p3so436750pgb.9
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:16:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=G8E+rJpVyLTQoZWEfd9l8Yi8PuLGKA2rJdGSnf5/Kng=;
        b=bkxZ5igsnh/JD58DPxcoPBhAYK+BQz7ACNUwxMf4gk/u5FymercBQR2KhZyxjb3FYZ
         JZiSHpTCCg8aHADYLHwUnJnHM7kGthaas1W4MEHaFCqGHoLPtqhU1KS6EmzyAUUCSNl7
         U9mjMa7MurDWuAxEGYohe9KDTOS+ATs8gCAcI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=G8E+rJpVyLTQoZWEfd9l8Yi8PuLGKA2rJdGSnf5/Kng=;
        b=sn5L7geAU3M45mHBbQXyqTDMV0Wb0q30TtjDWY0jNxfHMOjXGyFE55xaVV4qWcZD/r
         3b55LNxbbeX4ht4M5Eho+oq8Yv8Iq2akCzXgLxupuyyaf+K1eMhKVA/5shvi7NGw5bX7
         CK/aw6f1pCVOTUEiZWDgCCBKWmJEjp2+DuFF2DFxC2BfU1sDARDLITifqaYhZ1eMxxn5
         DB1NINAbWVdJkR1VyvACrukBRfnE8eFR4rIc4kBDCs/hhKsxwGadanzAS3Q20EfDLSyd
         KjhUHnlQeOCvySwjWlRLayEeU74oHuCehNHwPJCoIF49lipPV5HwxKqbRtOvogNHwsHS
         BWMg==
X-Gm-Message-State: APjAAAVs8WUz71HrxuaPhugwfEclytAFkrJV62M8ztNbakH3GS5y0Es2
	9E5tlOeMczvHDpVdonbENb9zBw==
X-Google-Smtp-Source: APXvYqzPn+wvrZiTi8+K95Bh/aZxRdY7i083QL+BtsT3mL9jZmsLF7wA0MTHcqpa0AC2oHg2i6qA/Q==
X-Received: by 2002:a62:b60e:: with SMTP id j14mr2722718pff.54.1565828213449;
        Wed, 14 Aug 2019 17:16:53 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id m4sm1197573pff.108.2019.08.14.17.16.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 17:16:52 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	x86@kernel.org,
	aryabinin@virtuozzo.com,
	glider@google.com,
	luto@kernel.org,
	linux-kernel@vger.kernel.org,
	mark.rutland@arm.com,
	dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org,
	gor@linux.ibm.com,
	Daniel Axtens <dja@axtens.net>
Subject: [PATCH v4 0/3] kasan: support backing vmalloc space with real shadow memory
Date: Thu, 15 Aug 2019 10:16:33 +1000
Message-Id: <20190815001636.12235-1-dja@axtens.net>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
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
 - https://bugzilla.kernel.org/show_bug.cgi?id=3D202009
 - https://lkml.org/lkml/2018/7/22/198
 - https://lkml.org/lkml/2019/7/19/822

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
v4: Changes to patch 1 only:
 - Integrate Mark's rework, thanks Mark!
 - handle the case where kasan_populate_shadow might fail
 - poision shadow on free, allowing the alloc path to just
     unpoision memory that it uses

Daniel Axtens (3):
  kasan: support backing vmalloc space with real shadow memory
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC

 Documentation/dev-tools/kasan.rst | 60 +++++++++++++++++++++++++++
 arch/Kconfig                      |  9 +++--
 arch/x86/Kconfig                  |  1 +
 arch/x86/mm/kasan_init_64.c       | 61 ++++++++++++++++++++++++++++
 include/linux/kasan.h             | 24 +++++++++++
 include/linux/moduleloader.h      |  2 +-
 include/linux/vmalloc.h           | 12 ++++++
 kernel/fork.c                     |  4 ++
 lib/Kconfig.kasan                 | 16 ++++++++
 lib/test_kasan.c                  | 26 ++++++++++++
 mm/kasan/common.c                 | 67 +++++++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |  3 ++
 mm/kasan/kasan.h                  |  1 +
 mm/vmalloc.c                      | 28 ++++++++++++-
 14 files changed, 308 insertions(+), 6 deletions(-)

--=20
2.20.1



Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4813BC3A59F
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:38:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA22D21670
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 00:38:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="pu31SPJC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA22D21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F39D6B0003; Thu, 29 Aug 2019 20:38:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CB356B0008; Thu, 29 Aug 2019 20:38:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA8C6B000D; Thu, 29 Aug 2019 20:38:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id E07336B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:38:39 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 952511E086
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:38:39 +0000 (UTC)
X-FDA: 75877233558.10.rain12_4b84779376545
X-HE-Tag: rain12_4b84779376545
X-Filterd-Recvd-Size: 6365
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:38:38 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id n9so2547222pgc.1
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 17:38:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DSLyHXthXaKXOQZ8SFsqItHK5pHRiDWtPuxcUQu12HE=;
        b=pu31SPJCi+AOP3zXr9+aDjC5rxpyExfuNsXBpNJ+U/17mstU+JX99GwniAgq5X7Pa5
         yWJd36SGMJDkYzN0HburXGQx9v3j6tk4ubUO1WEIePNUdsLuWxfV6CECGk+H9RDp/4Wa
         KMmLen85d+fQ7Ang26OUP+xrxgFhMbghKZgII=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DSLyHXthXaKXOQZ8SFsqItHK5pHRiDWtPuxcUQu12HE=;
        b=nvtNqULoe08ridmHrkQOBVNAtnMfmriOUMOmWJLWOvtHhsvxstHbmXloMQ1vVn95ao
         jDOlnH2jg0y7sRVITqMlqhbe3PGJsBXdzmiFnkGCafTmdKIjPYw1NMYQbb31o9nYi7mT
         8EucaEYZXjmBAuzK+bZBxFqAUwyzR2AJjL7akCX0Gux60n/Yy1F2Z1NhQT4J+TkdT8Cq
         c/Add69g5pF8T1I6/6rhqqP832tVPwJXLv/jh7RqxR4OeTNyuygCpHu/EEo/9KmjkAKz
         kw91zICWDn10jJfBdgIGmrHjUdP+NoNyrTcMC9nTX6mU1XLernm9Br4AEKRtTwk2ezWj
         b2MA==
X-Gm-Message-State: APjAAAU/vqqu7k7Ebl0KTSMSpSHD0LrTeiNF4BgTBNctZDDXtuogeGKq
	m7O3AYmFT2j8R7kPVY7NFp5yqA==
X-Google-Smtp-Source: APXvYqySp87qZozbuG9m12UZb0GG3l4jvENITo2xlt52HkVNyUOk8lyBYyVA9FdFCHiOprawlyDAQA==
X-Received: by 2002:a63:9245:: with SMTP id s5mr10952781pgn.123.1567125517640;
        Thu, 29 Aug 2019 17:38:37 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id a16sm4341162pfk.5.2019.08.29.17.38.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Aug 2019 17:38:36 -0700 (PDT)
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
Subject: [PATCH v5 0/5] kasan: support backing vmalloc space with real shadow memory
Date: Fri, 30 Aug 2019 10:38:16 +1000
Message-Id: <20190830003821.10737-1-dja@axtens.net>
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
v5: Address comments from Christophe Leroy:
 - Fix some issues with my descriptions in commit messages and docs
 - Dynamically free unused shadow pages by hooking into the vmap book-kee=
ping
 - Split out the test into a separate patch
 - Optional patch to track the number of pages allocated
 - minor checkpatch cleanups

Daniel Axtens (5):
  kasan: support backing vmalloc space with real shadow memory
  kasan: add test for vmalloc
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC
  kasan debug: track pages allocated for vmalloc shadow

 Documentation/dev-tools/kasan.rst |  63 +++++++++++
 arch/Kconfig                      |   9 +-
 arch/x86/Kconfig                  |   1 +
 arch/x86/mm/kasan_init_64.c       |  60 +++++++++++
 include/linux/kasan.h             |  31 ++++++
 include/linux/moduleloader.h      |   2 +-
 include/linux/vmalloc.h           |  12 +++
 kernel/fork.c                     |   4 +
 lib/Kconfig.kasan                 |  16 +++
 lib/test_kasan.c                  |  26 +++++
 mm/kasan/common.c                 | 170 ++++++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |   3 +
 mm/kasan/kasan.h                  |   1 +
 mm/vmalloc.c                      |  45 +++++++-
 14 files changed, 437 insertions(+), 6 deletions(-)

--=20
2.20.1



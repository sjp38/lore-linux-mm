Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02940C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D611218A6
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 07:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="AHPx62HM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D611218A6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72978E0003; Wed, 31 Jul 2019 03:15:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFB608E0001; Wed, 31 Jul 2019 03:15:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC3858E0003; Wed, 31 Jul 2019 03:15:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94EBA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 03:15:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so42627054pfb.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 00:15:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=pBb3SjcJAJvGT3ZKVh7XtBW59bi/thuEuHRFZNsNtKI=;
        b=QlwpQKua+hK2jTG3NOvX6MpH+x+zcKnQLQ0mtE+XSxul1sn4K8KgHbpO3HU+cLTUcJ
         hKt6srNqf+2lytpZP5wcjgntzBYs8iw9kiPbkyWPkRi2XXHOACwrvx+aD/JdeJH70zcl
         5oV8pkc26HDkEVDGRDUkGDqBycz317iiCC1frXPClzvaSHPNtka6+La+3hH8toISMCax
         55YZRemotdJGskW0MjUIVu2GbMD2EC/YDF23jkJ6sFNSic+XxXYbSFdJoADV9DygC6+S
         hNeMwbRFnl3lwE0XMwz3I+4kAhoQjTOdoKgb/6BDcQDYGMMNIFdEFgwv0i/c7WyNe6Op
         8Ukw==
X-Gm-Message-State: APjAAAWT7HSVy9FCN2aWs3crmDqYgY422s/7s/QplLX7+inGyhe0ySYa
	FKsrdig20nkzzuMWJ4cnRe0C4xhU45A9uz+lzVY49Mue+K0tsfYdoeitXO4up1u7MuYaX3Xm5Qx
	4cddc9Q7gORPYUJR07OUN1ckrtKClzhDR34LzhsJZDWphgFmkqezriS95pc9iaKzSHg==
X-Received: by 2002:a17:902:7781:: with SMTP id o1mr118919845pll.205.1564557357111;
        Wed, 31 Jul 2019 00:15:57 -0700 (PDT)
X-Received: by 2002:a17:902:7781:: with SMTP id o1mr118919797pll.205.1564557356261;
        Wed, 31 Jul 2019 00:15:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564557356; cv=none;
        d=google.com; s=arc-20160816;
        b=d7SEw/QIARwL25LYW88Ecr/H+MhkDozYcMt/8DwPFx7OUK6KEoTBLJM+Fu1DxtcEcZ
         LhAurvQh0X8f6Bt4DOJAaTKsu634m3N3om0p9s4B6aoD7J7lIRjUa+HC6AIxpiTxZjn5
         PwA1PeK8w879S7iWfaupV6Qa7GXk6S6zo77Ebs/ixXydhf6QwW+iLIvKl/IcA/gxohzH
         gNpCkSsGZvsbcHtCqtoiHau1f06H4m/nR/Tojf6uTcz7kloPBUy2K7tu8xR39AZbFm1W
         2StOZ+GYnCKq44PR3j7rtcMVnEokC9bisYGJbOFKWthXvFaUB9vluoz5nmg5F1f6+d1q
         IvuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=pBb3SjcJAJvGT3ZKVh7XtBW59bi/thuEuHRFZNsNtKI=;
        b=ow9Qe+CEjLpO/36R1I9kC2JMUveuA91idBHyFIROmK0rKMtZzyrfiqhOQVGs9Abth4
         7nQTrbV9emDRdnT5pgXeiedY/e6DCXE50DjqYC4i6RxMIQi88NrJXpbMXebSOTto59ng
         UNBR0dW+NmYqMB5Ss4H3wTHIzh/tZjUR9Wh4WLZBR2cN5aMoYui+KNHzDFN9pJT2Gew4
         J2kUIE9o7LATBawIC1mv8MBhOmmZPqXY6gHrM+uhQydiG12UUPeSyZV9gM53SCvAJ2gS
         DX92Wy/0i/5Uo3dd2tGT0pNgZmMludIGZC4Zs1Wv6OMEjcSbOhUwnb9tPz/dafxtXipH
         xQeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=AHPx62HM;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p61sor1002038pjp.0.2019.07.31.00.15.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 00:15:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=AHPx62HM;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=pBb3SjcJAJvGT3ZKVh7XtBW59bi/thuEuHRFZNsNtKI=;
        b=AHPx62HMhQa8hHRMGLqgFiw+CumV6LiEgGPvYRqjcrvfGuwSMk4T9h6ZBLhXoSWrCI
         K8hKp875yeBKlerrIoeiIERsQFuw95uNk88vGcgWCgVb/quRyN0yqEth5OX9ZrewsaRf
         QpRSPaGOI1njJ5BGhn1bmjkrIUghufDipHuDQ=
X-Google-Smtp-Source: APXvYqy/mIDPTuA13zSYqCYHNuz1kgkm/st7Gu7Y8W/1GxIxmP0Q7ged7lvL97JvsdwucbKkDwzDjw==
X-Received: by 2002:a17:90a:29c5:: with SMTP id h63mr1357413pjd.83.1564557355793;
        Wed, 31 Jul 2019 00:15:55 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id x13sm71508648pfn.6.2019.07.31.00.15.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 00:15:55 -0700 (PDT)
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
Cc: Daniel Axtens <dja@axtens.net>
Subject: [PATCH v3 0/3] kasan: support backing vmalloc space with real shadow memory
Date: Wed, 31 Jul 2019 17:15:47 +1000
Message-Id: <20190731071550.31814-1-dja@axtens.net>
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

v1: https://lore.kernel.org/linux-mm/20190725055503.19507-1-dja@axtens.net/
v2: https://lore.kernel.org/linux-mm/20190729142108.23343-1-dja@axtens.net/
 Address review comments:
 - Patch 1: use kasan_unpoison_shadow's built-in handling of
            ranges that do not align to a full shadow byte
 - Patch 3: prepopulate pgds rather than faulting things in
v3: Address comments from Mark Rutland:
 - kasan_populate_vmalloc is a better name
 - handle concurrency correctly
 - various nits and cleanups
 - relax module alignment in KASAN_VMALLOC case

Daniel Axtens (3):
  kasan: support backing vmalloc space with real shadow memory
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC

 Documentation/dev-tools/kasan.rst | 60 ++++++++++++++++++++++
 arch/Kconfig                      |  9 ++--
 arch/x86/Kconfig                  |  1 +
 arch/x86/mm/kasan_init_64.c       | 61 +++++++++++++++++++++++
 include/linux/kasan.h             | 16 ++++++
 include/linux/moduleloader.h      |  2 +-
 kernel/fork.c                     |  4 ++
 lib/Kconfig.kasan                 | 16 ++++++
 lib/test_kasan.c                  | 26 ++++++++++
 mm/kasan/common.c                 | 83 +++++++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |  3 ++
 mm/kasan/kasan.h                  |  1 +
 mm/vmalloc.c                      | 15 +++++-
 13 files changed, 291 insertions(+), 6 deletions(-)

-- 
2.20.1


Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26CFAC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBB642083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:42:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AR5AIo/F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBB642083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64F976B0007; Thu, 18 Apr 2019 11:42:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FEFB6B0008; Thu, 18 Apr 2019 11:42:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 515B26B000A; Thu, 18 Apr 2019 11:42:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA876B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:42:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so1607618pfi.20
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=c6cte1GA0N3UXNBho2QutaVeM3bmO26Ex5C2Za+9lAo=;
        b=gFe7gdoIpbj1v8/+QvONd36q1zHXyzSmacZdNPe+YjZ6bnIxQbCmjMWpR8tdAjwb8M
         EBTXqSAWYtps2AGcMskQsTr4NmbfOQDcqh9sbiN/eskjHwQWFRfdHTflDRUHo4CwSSZj
         m43d4kQFA5EBxy8TO+kuW3NNrv+xZf+jcjh2tvccY4gFo16/J0jNvLgI5hvgoLQZo+i1
         Gamg3miJxRlvpZVcdgtBfdFd/UDCb/9XmnsDU4YrnbBPyrDVA+1q1UN7nXmMXC/v34C0
         83sj5uHJNtcD3qpf3Gxf0NN+Q0w0sHc6Zo7lnkqyNekQxMcMofc8kc4G20c7djrLVYRc
         n6Rg==
X-Gm-Message-State: APjAAAVZAOTzbozDfJ7/9h2lKUbtPojds75X6I8bIIi8R6NnixJWu4RE
	nZGnmIw1beoMiS9CsFJTZ76tifxhFMLRl9Kii2Ix337Ma7WZo586i9nk35yzB1H+XuDGUiOt5bL
	xjFap0IUNjLd2ac8xH9C6VpIkzDLl80UVtGWx8+rSpvgD+ueiWw+doZvt/ynjGQF4cg==
X-Received: by 2002:a63:6804:: with SMTP id d4mr42752175pgc.240.1555602147556;
        Thu, 18 Apr 2019 08:42:27 -0700 (PDT)
X-Received: by 2002:a63:6804:: with SMTP id d4mr42752111pgc.240.1555602146599;
        Thu, 18 Apr 2019 08:42:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602146; cv=none;
        d=google.com; s=arc-20160816;
        b=pLBz2gaBzDFG79H8jbJO5KlEgnAUK8NejE+XDJY1cBbVinDlYP3GjxU1Pa70aXxHix
         gAyuvJI0nc3TsYbDNaB4H1PyhRx7Yn521T/EbEoHgN1QxhxnvM/51nBNHWS/i9FWOG36
         mL77n4lYF7wigXULXBAmYlN2H8BJm16n5WagvANxSi1Ukcb2RL3bFrBqzlSMYVrlX1R6
         eKQHTyr2b571bEZ2rCtnFK3vlxOAK3o0TVGEvTw3NoLMKiKhqp/ZNYpiACzlOc4/YYiu
         FsFI8WMCIMUh9dKKdJzLdyz26bSjoJJIiPJ8w44lPLg4t6y2+fxjTgyY8dMjSLyAp9HX
         gnMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=c6cte1GA0N3UXNBho2QutaVeM3bmO26Ex5C2Za+9lAo=;
        b=HYIuWOgCwTSszGYKvhGcuBPdLWeJLJ1x2of3ChVnjO0XkYB6DgB9t1YiLM+7Mfv44U
         FW9Ku47ujHEJHat70T6ULV5HsGWy4hhaUyy2qoF89je5eL13oOLVehoadZ//U/nVT+A2
         dYy7krJty2lDqrN0PVelQKaFjF6jG8Udt0U9sixvk9ePsYDV8ooILMvKp5i9aalt6pEr
         /Z7fjQ9Ka1HVlEEbR9GfSqSMePyrdEW4GMykynu3KSlcDPDWyCR0ahlMuFXr2zJw7mPp
         KddDWhFls4C9Aa+qFaL1DsJwHDKow85+kq1b7kXgx4WIE7+j7zeQgjrG5cEAlb6qHdYb
         VrGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="AR5AIo/F";
       spf=pass (google.com: domain of 34zq4xaykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34Zq4XAYKCOQMROJKXMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g2sor2367147pgl.60.2019.04.18.08.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 08:42:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 34zq4xaykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="AR5AIo/F";
       spf=pass (google.com: domain of 34zq4xaykcoqmrojkxmuumrk.iusrotad-ssqbgiq.uxm@flex--glider.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=34Zq4XAYKCOQMROJKXMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--glider.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=c6cte1GA0N3UXNBho2QutaVeM3bmO26Ex5C2Za+9lAo=;
        b=AR5AIo/FYzzbLDe/+9fNlgTRd1JlWeeO5nMeBPeV46W1GkksSc+qaMrdyXrh5Do9QE
         JrAtIvsVVJYnQicJlXhQWt6iN8wTEm+Zqyxz68lkMJv3246rOgmqdPmxWUZ3jloUjdIm
         1+UN9Hq82jsq3ts0wfHArPjrYSr916UnXKE1cST6NOrZaHvJUxwdwq9X4Pw9HAeX+fbT
         s2IWr2t82RK50Pd/YxBLEWUZI18RibVNAJ98YbilJoXUdXr/aLXfT+cZ3in1fV5ZC3fE
         POKFx+4dSkY2PAvonxY4ahEyxLlH7ueLjdZnRhhaZbB3BNqsWAYxHqkgeEMvFGkVGFnC
         t8cA==
X-Google-Smtp-Source: APXvYqzlWFUlYk1TyzNFNdkmxacEV9kEkpY+WAHWzfS82vhaZYY6jgkKpDzAz2ONekaghvjOar/WrEYb+3w=
X-Received: by 2002:a63:170d:: with SMTP id x13mr90021965pgl.169.1555602145919;
 Thu, 18 Apr 2019 08:42:25 -0700 (PDT)
Date: Thu, 18 Apr 2019 17:42:05 +0200
Message-Id: <20190418154208.131118-1-glider@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [PATCH 0/3] RFC: add init_allocations=1 boot option
From: Alexander Potapenko <glider@google.com>
To: akpm@linux-foundation.org, cl@linux.com, dvyukov@google.com, 
	keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org, 
	kernel-hardening@lists.openwall.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Following the recent discussions here's another take at initializing
pages and heap objects with zeroes. This is needed to prevent possible
information leaks and make the control-flow bugs that depend on
uninitialized values more deterministic.

The patchset introduces a new boot option, init_allocations, which
makes page allocator and SL[AOU]B initialize newly allocated memory.
init_allocations=0 doesn't (hopefully) add any overhead to the
allocation fast path (no noticeable slowdown on hackbench).

With only the the first of the proposed patches the slowdown numbers are:
 - 1.1% (stdev 0.2%) sys time slowdown building Linux kernel
 - 3.1% (stdev 0.3%) sys time slowdown on af_inet_loopback benchmark
 - 9.4% (stdev 0.5%) sys time slowdown on hackbench

The second patch introduces a GFP flag that allows to disable
initialization for certain allocations. The third page is an example of
applying it to af_unix.c, which helps hackbench greatly.

Slowdown numbers for the whole patchset are:
 - 1.8% (stdev 0.8%) on kernel build
 - 6.5% (stdev 0.2%) on af_inet_loopback
 - 0.12% (stdev 0.6%) on hackbench


Alexander Potapenko (3):
  mm: security: introduce the init_allocations=1 boot option
  gfp: mm: introduce __GFP_NOINIT
  net: apply __GFP_NOINIT to AF_UNIX sk_buff allocations

 drivers/infiniband/core/uverbs_ioctl.c |  2 +-
 include/linux/gfp.h                    |  6 ++++-
 include/linux/mm.h                     |  8 +++++++
 include/linux/slab_def.h               |  1 +
 include/linux/slub_def.h               |  1 +
 include/net/sock.h                     |  5 +++++
 kernel/kexec_core.c                    |  4 ++--
 mm/dmapool.c                           |  2 +-
 mm/page_alloc.c                        | 18 ++++++++++++++-
 mm/slab.c                              | 14 ++++++------
 mm/slab.h                              |  1 +
 mm/slab_common.c                       | 15 +++++++++++++
 mm/slob.c                              |  3 ++-
 mm/slub.c                              |  9 ++++----
 net/core/sock.c                        | 31 +++++++++++++++++++++-----
 net/unix/af_unix.c                     | 13 ++++++-----
 16 files changed, 104 insertions(+), 29 deletions(-)

-- 
2.21.0.392.gf8f6787159e-goog


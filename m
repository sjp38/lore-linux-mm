Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8758AC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4087A2070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:21:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="h0ssI4U9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4087A2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B68DF8E0005; Mon, 29 Jul 2019 10:21:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1A728E0002; Mon, 29 Jul 2019 10:21:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A083F8E0005; Mon, 29 Jul 2019 10:21:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3838E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:21:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3so38326696pgc.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:21:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=MR80kuJNJTZu3hsDXBNA4q0a6EH0Ziu81Ow2DeGUsWQ=;
        b=cifybLsj6yR5FEgEBWViKzQh5668xTUkdUuTPnBceGaajuzfpvNRlwuMS2GnC6/voz
         dQ/iREb0r90I9nBpCbv2S8kqlYSXI+Jkj9sQPgXN1alTB67n8tMUizNz0x4EqIixQJo5
         gYAUQQWXPNG6om0pxF8eX0FZwFv7deUqF6j+IgpdZoz/sLQlmcO0qmE/aIWK5Uubpz6/
         ntinOBEfP+8zmiNkwnaNqQRXLGehjxHfEMnV+aH6s4ZxrW2vTZyO7d9MYJ0MVt2ctcuZ
         R4uNFVRt8Q3L+HqASJzhkHfwz4amoUCA1MBZwBA8o8p5BHzsGe2UdBlmqZ+0sJn9HoWX
         IoQw==
X-Gm-Message-State: APjAAAUaclXLUc+WR2hNXYVS+MH45UYSZJgWHhvY/sIAVbiMOkDPd1rQ
	Z84enOeQDDLZjgN1+fgMmE38AeKpG0ndz/11op3JcSehGe2NFpYVK1XqvNAo2P6HMVDb0B3UmaO
	ak0H8gZ26P0uwg08dUMozEkdsFbN+0wVIRrPDggNc5dSqdQLnyscrCmvvdUERZmmERQ==
X-Received: by 2002:aa7:92cb:: with SMTP id k11mr37361353pfa.126.1564410076975;
        Mon, 29 Jul 2019 07:21:16 -0700 (PDT)
X-Received: by 2002:aa7:92cb:: with SMTP id k11mr37361274pfa.126.1564410075961;
        Mon, 29 Jul 2019 07:21:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410075; cv=none;
        d=google.com; s=arc-20160816;
        b=0tBxTNc/4QQZxvvEA5dZIqA3nM6ow48Hdckx22RuhErXrsEt1zxjQBzsMlxdBbqUfU
         P7qPqJkQf+1dGo5FhOSjDTkNsc0vox6mIOY/iHK7Wd+xn0oqM75f0CbqvgYKJ9VMTO5C
         YvCCQ+099MPKNncHSDzHqZDz+t61vp7JtqzuWHnr2R8ET45JU8DBw2ooRkxkqgaQYwr3
         ULHCzeHKHvKCpRbpiXX5ODcSWXGQ7/YBgJd792O3pG84B30nGn+xRozh2RFfTRhTk+/d
         ISd1/N3zEJHHbHglE2jYzk9Ze9LDSGyGVkSFpPmOFDR1BomZkwEj8IQ+jEFbkwY7izy8
         p4Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=MR80kuJNJTZu3hsDXBNA4q0a6EH0Ziu81Ow2DeGUsWQ=;
        b=r0hknZOg8wVX/rI466ZzWUT/GhvrYbJE4Cnr7DNcK/p3LdYn1ar0V4kLa+Ql45Gq+U
         F6K39mTQjtbKTqZ1X+ZEC5PYC6QwjikZ1jHJ0ORsK55o755Adnk70iyG7gUYAZop9kB3
         XfxjlGbpms/MyAnk8yWCvJGl8hTY7wKEvscMHx50lfe6xxRC8DOBenx1Gak4TfHJ5P2t
         BrOm3aUyNpYyCci0+rQVnU3vMwoOS+MT6WWvM78ut5ckv/PUMpK7XhFSMve1/bI1TgZu
         FfStUivJjhyt5RpyrPMcvV5W6j8rMO8CmhyjqqUoMQtWD7rqPs9GJQn+A9yW26qHgJjX
         3MAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=h0ssI4U9;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15sor39671863pgs.16.2019.07.29.07.21.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 07:21:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=h0ssI4U9;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=MR80kuJNJTZu3hsDXBNA4q0a6EH0Ziu81Ow2DeGUsWQ=;
        b=h0ssI4U9wjp1jVnPVOHReehDKSp/8jrXd6kfiCYoB88CDRXMFy2VsMgLb+53mXG8bG
         3ujADxDfBwHH4B+TJVQ6UAg5vsOk4SuC11JrrYhLuSrXg95iTBogwJtxcsGAcXjeIKnL
         KaxuntdgTbDi+hdcJ2sKgSBYjdoV9yWT8GYrQ=
X-Google-Smtp-Source: APXvYqwIXlupdIi6PkUXUFGu9oV4z+WuZwgZVgPFpcMgqr1bkVfNbExq9CxRoUE4mt0Rvi0fm5ynYA==
X-Received: by 2002:a63:c008:: with SMTP id h8mr102953637pgg.427.1564410075414;
        Mon, 29 Jul 2019 07:21:15 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id i3sm67061225pfo.138.2019.07.29.07.21.13
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:21:14 -0700 (PDT)
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
Subject: [PATCH v2 0/3] kasan: support backing vmalloc space with real shadow memory
Date: Tue, 30 Jul 2019 00:21:05 +1000
Message-Id: <20190729142108.23343-1-dja@axtens.net>
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

v1: https://lore.kernel.org/linux-mm/20190725055503.19507-1-dja@axtens.net/T/
v2: address review comments:
 - Patch 1: use kasan_unpoison_shadow's built-in handling of
            ranges that do not align to a full shadow byte
 - Patch 3: prepopulate pgds rather than faulting things in

Daniel Axtens (3):
  kasan: support backing vmalloc space with real shadow memory
  fork: support VMAP_STACK with KASAN_VMALLOC
  x86/kasan: support KASAN_VMALLOC

 Documentation/dev-tools/kasan.rst | 60 ++++++++++++++++++++++++++++++
 arch/Kconfig                      |  9 +++--
 arch/x86/Kconfig                  |  1 +
 arch/x86/mm/kasan_init_64.c       | 61 +++++++++++++++++++++++++++++++
 include/linux/kasan.h             | 16 ++++++++
 kernel/fork.c                     |  4 ++
 lib/Kconfig.kasan                 | 16 ++++++++
 lib/test_kasan.c                  | 26 +++++++++++++
 mm/kasan/common.c                 | 51 ++++++++++++++++++++++++++
 mm/kasan/generic_report.c         |  3 ++
 mm/kasan/kasan.h                  |  1 +
 mm/vmalloc.c                      | 15 +++++++-
 12 files changed, 258 insertions(+), 5 deletions(-)

-- 
2.20.1


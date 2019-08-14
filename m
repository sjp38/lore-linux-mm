Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6806BC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E39A12084F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 20:20:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="SVq5cWxf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E39A12084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E0DE6B0007; Wed, 14 Aug 2019 16:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5911F6B0008; Wed, 14 Aug 2019 16:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47F7D6B000A; Wed, 14 Aug 2019 16:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id 2071F6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:20:36 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B65DB3D12
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:35 +0000 (UTC)
X-FDA: 75822151230.21.toe50_52164d452614
X-HE-Tag: toe50_52164d452614
X-Filterd-Recvd-Size: 3902
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:20:35 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id s49so385160edb.1
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:20:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nWZWsKOfmIl4yNVyC1A/XslquByM6vO1WGS7Kz0bD8U=;
        b=SVq5cWxfnMTCbnzjMxfAenRqPrywZHCY7aSYPqhjndhFoxhSpIaewsuAAbQ+hxRege
         LlE77zS9n3UHrI63NXV/R4kzhjhCsYIyspu6VzmOq3rB3oTT4FTYaoEIf2AXE4TNZw67
         EpRfZR5Lx03CDLH2/rXob/8M+d0YAjVHOhE5s=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nWZWsKOfmIl4yNVyC1A/XslquByM6vO1WGS7Kz0bD8U=;
        b=Qat97CHekUYpzYZJ5AkpazRuJDfOXtrwgAoCkVsEaVnIlYyPP1k6F8fA7C6OQN98dp
         Kp8nrgqgh4N0OvPjwa/5L8iCs6O5vg6Q4JyaQi/tz066GLF3adIZj8jhHdyQ3Az9UU84
         SCpVQ6YoOuOxDCiEyAeexFfbXetdeidHVfDfqCoifmJaHbySgUSg2xqcIbzEySEq5faQ
         PedwyGhgr+zX+6HQBe+JXJvCIXg9Sgx457Pc8TdMHfeUY1rlXpyVFlAdjAM/ClY3nwYL
         DdVdZYOrAxhe+tqM4wtXOaX+3XJkskrWzEkOJ6/mgfWHsGH71hbN7cwdXVG9kZ5ORY5v
         OPTw==
X-Gm-Message-State: APjAAAW6aPS38sk/IPyzBGNN4XFN/r57ULgpHOnxdfwF/5NMF1s5PeIG
	NntNlpI/kihb6U2rFqo1h+TUhg==
X-Google-Smtp-Source: APXvYqw0SI+1ky3oT9vQxF5bI61NxCDkMXiJWr+jVakG6fqDm3c/lfxYyJWqP0bvugFJUIGMMW1jXQ==
X-Received: by 2002:a17:906:5042:: with SMTP id e2mr1299846ejk.220.1565814033793;
        Wed, 14 Aug 2019 13:20:33 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id ns22sm84342ejb.9.2019.08.14.13.20.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 13:20:33 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 0/5] hmm & mmu_notifier debug/lockdep annotations
Date: Wed, 14 Aug 2019 22:20:22 +0200
Message-Id: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all (but I guess mostly Jason),

Finally gotten around to rebasing the previous version, fixing the rebase
fail in there, update the commit message a bit and give this a spin with
some tests. Nicely caught a lockdep splat that we're now discussing in
i915, and seems to not have misfired anywhere else (including a few oom).

Review, comments and everything very much appreciated. Plus I'd really
like to land this, there's more hmm_mirror users in-flight, and I've seen
some that get things wrong which this patchset should catch.

Thanks, Daniel

Daniel Vetter (5):
  mm: Check if mmu notifier callbacks are allowed to fail
  kernel.h: Add non_block_start/end()
  mm, notifier: Catch sleeping/blocking for !blockable
  mm, notifier: Add a lockdep map for invalidate_range_start
  mm/hmm: WARN on illegal ->sync_cpu_device_pagetables errors

 include/linux/kernel.h       | 10 +++++++++-
 include/linux/mmu_notifier.h |  6 ++++++
 include/linux/sched.h        |  4 ++++
 kernel/sched/core.c          | 19 ++++++++++++++-----
 mm/hmm.c                     |  3 +++
 mm/mmu_notifier.c            | 17 ++++++++++++++++-
 6 files changed, 52 insertions(+), 7 deletions(-)

--=20
2.22.0



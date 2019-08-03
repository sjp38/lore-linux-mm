Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58FD3C433FF
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A4B2166E
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 14:02:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tfT01MLu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A4B2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6A36B000A; Sat,  3 Aug 2019 10:02:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6E16B000C; Sat,  3 Aug 2019 10:02:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BBFE6B000D; Sat,  3 Aug 2019 10:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 582E36B000A
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 10:02:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k13so67553474qkj.4
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 07:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id;
        bh=AiTM5WxUhwBn/0+fPLrU4NXRLZPLKnlQS1xIhWaJzpg=;
        b=Q4lCRv6iEiliJq+IFFQfOOzUlGwSRRUipks74TEe2l9jR3ehYyTjp80I6serHiNUrF
         XyoZuH2wf4ggTCDzJAzToiZBvshN6lxx1SQw9ABsM8mPlSJmt0ek9T8ryU/DkqEu/Ogc
         bSs6UnQUlZ+siZNHgX41PVJGmAmjE2daXm6od/ypfzPLGuETRI35sHY0OkuTqBLNGPwP
         DDDkS6NP7a3cmTIwLw5Ej6mGbyw5/6AU9UJcZp2CBixD3b825DUVgGMD1G7MHpTfR+YP
         J5zg7cdefOsw41X/K5VCQFI2rqH3+6dE7EWiS96c8yY4S/QbMLNWvYlAakrbKLP+D6KF
         AxwA==
X-Gm-Message-State: APjAAAXNF6Ev+3CwOiBXJ91Jcju19WpJtkS0yEHKrP0IvrS6IjH9Kxye
	/Aq8/Kib8UX1txioDgvOL5VRHzIvyUax6jdgVm7fWF0e0yGdHF19qwvPO59OXCluLeek0MySCZL
	7cA7hws/qdxgZLtYV1ej6GG3eJylMW0ROk5cB6+7rHd99kYiDWR3qL8UXEQnxb5Y=
X-Received: by 2002:aed:2336:: with SMTP id h51mr97444115qtc.125.1564840923064;
        Sat, 03 Aug 2019 07:02:03 -0700 (PDT)
X-Received: by 2002:aed:2336:: with SMTP id h51mr97444055qtc.125.1564840922309;
        Sat, 03 Aug 2019 07:02:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564840922; cv=none;
        d=google.com; s=arc-20160816;
        b=phlpWh3Wah8mav2T5rN+fawLbBWfnRt5BsKfpjpjnTuSGeUixM3qs9/xjcrBFdi1Ek
         mZn9KbAxzrFdseqedqSHtIrFnMLt3ZDr22wL7Y4plkV82Kpur7r0SBD6/KgAYIg1inq4
         970Jp9fEVZCQ5RwYuJ7u0q1lACB8z7AnOUxBZ31ZnG53/GDHsE5rhjzTBSnGvP0xel4C
         TxHZ36VQlxhRCzuFIRmk6Cfy3XmLM7lWYlXh2Ds5HtNwrRQ7ppSS5t3X4V4DP2Az5Ryh
         884p1XkZm1d+ncW4gaI2pOW1QbUKyL6vZKlNKrs8cq9rYFh50kec5vJfSbBFNgRV2WFL
         d5TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=AiTM5WxUhwBn/0+fPLrU4NXRLZPLKnlQS1xIhWaJzpg=;
        b=dmQVqdgfKtJjS5y4lNfykthm15W2VcI/AWY3gBjP7qwd8Geq59qYb/E4YfzHm6qpI9
         sJPCY70H8wlZ8o0sK8MPzBBe12mxSYwBTxaUTNM2XFYNQzTl0T5gsVTFlLK4JVn/5Dz6
         3hajzLbCbDfAnXvWBzpSLCa9JLsmsqB5nnjRP08AIL+tnNCL+tvwUQ6IH7FxtEpTPCwL
         vbrWh5JDLVvYL9ICOEEhF5qM3E3MnwroGzmI+p2s5ApoFFIkK/lYh9SPPWHQBvVIgR2Q
         M2ZI6t0bCZ/Nj9xL1AtUDCV7rR+jbNrmSzzEjl6iUB9v+a88UnFKwermqA4wYQU/o0iP
         174g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tfT01MLu;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor49012586qvh.25.2019.08.03.07.02.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Aug 2019 07:02:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tfT01MLu;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=AiTM5WxUhwBn/0+fPLrU4NXRLZPLKnlQS1xIhWaJzpg=;
        b=tfT01MLuJKUwtU61ZxhKrZL6uuTYcpg4nXhf60oe0IrgWdG+XWg7SytG8ERsq3bvX8
         A+e4WnbVDrMQxtUgmUCHknAGfXaYg+2CxcWZ2ZbT6n7dMSHoxs5u/cz8JXmfAqH/cBPt
         aXnpRRuUe2fQtDlx3L2JHIJwPUaNpVX5L6s+NZ/q9HjqbhhbPhoSd680vE+8vvxS8y8K
         /IjAIxVBjB2wm3P06AH/7CgQgSjnsSyc9euHSKr9iuS17mANP+9NnfW22gTMHIt/RGwY
         PQ2chv1aMEKUWdBpJywMQP3q7/mQrd3UQdDY+QtZLHmq3nSvFRpZdaBN1SmpQ5Ar2/IC
         tE3A==
X-Google-Smtp-Source: APXvYqzzgCoVrYOzV3Sh22dKmWqWg/eQVur3HjvBhsdIJFMLo/Q8sCxblPPzca1gNgyMp+0/Sw1UCw==
X-Received: by 2002:a05:6214:1c3:: with SMTP id c3mr94720009qvt.144.1564840921783;
        Sat, 03 Aug 2019 07:02:01 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::efce])
        by smtp.gmail.com with ESMTPSA id i62sm35045931qke.52.2019.08.03.07.02.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Aug 2019 07:02:01 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk,
	jack@suse.cz,
	hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	guro@fb.com,
	akpm@linux-foundation.org
Subject: [PATCHSET] writeback, memcg: Implement foreign inode flushing
Date: Sat,  3 Aug 2019 07:01:51 -0700
Message-Id: <20190803140155.181190-1-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

There's an inherent mismatch between memcg and writeback.  The former
trackes ownership per-page while the latter per-inode.  This was a
deliberate design decision because honoring per-page ownership in the
writeback path is complicated, may lead to higher CPU and IO overheads
and deemed unnecessary given that write-sharing an inode across
different cgroups isn't a common use-case.

Combined with inode majority-writer ownership switching, this works
well enough in most cases but there are some pathological cases.  For
example, let's say there are two cgroups A and B which keep writing to
different but confined parts of the same inode.  B owns the inode and
A's memory is limited far below B's.  A's dirty ratio can rise enough
to trigger balance_dirty_pages() sleeps but B's can be low enough to
avoid triggering background writeback.  A will be slowed down without
a way to make writeback of the dirty pages happen.

This patchset implements foreign dirty recording and foreign mechanism
so that when a memcg encounters a condition as above it can trigger
flushes on bdi_writebacks which can clean its pages.  Please see the
last patch for more details.

This patchset contains the following four patches.

 0001-writeback-Generalize-and-expose-wb_completion.patch
 0002-bdi-Add-bdi-id.patch
 0003-writeback-memcg-Implement-cgroup_writeback_by_id.patch
 0004-writeback-memcg-Implement-foreign-dirty-flushing.patch

0001-0003 are prep patches which expose wb_completion and implement
bdi->id and flushing by bdi and memcg IDs.

0004 implement foreign inode flushing.

Thanks.  diffstat follows.

 fs/fs-writeback.c                |  111 ++++++++++++++++++++++++----------
 include/linux/backing-dev-defs.h |   23 +++++++
 include/linux/backing-dev.h      |    3 
 include/linux/memcontrol.h       |   35 ++++++++++
 include/linux/writeback.h        |    4 +
 mm/backing-dev.c                 |   65 +++++++++++++++++++-
 mm/memcontrol.c                  |  125 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |    4 +
 8 files changed, 335 insertions(+), 35 deletions(-)

--
tejun


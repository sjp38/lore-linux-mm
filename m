Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DDE2C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 329B920674
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 16:07:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LSTEt2ds"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 329B920674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B140C6B05AF; Mon, 26 Aug 2019 12:07:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC50C6B05B1; Mon, 26 Aug 2019 12:07:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98C286B05B2; Mon, 26 Aug 2019 12:07:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id 766D76B05AF
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 12:07:05 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 25B0B180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:07:05 +0000 (UTC)
X-FDA: 75865058010.21.birth09_5ae9b53ae2852
X-HE-Tag: birth09_5ae9b53ae2852
X-Filterd-Recvd-Size: 5519
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:07:04 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id p13so14436069qkg.13
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:07:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=80iUPmrcBk2+ug2egAEGLlkODFGV0leLCrkusgfj0dU=;
        b=LSTEt2dsSUlYWtlWtHYVxk6WiPYZB0AVIJmO+3gPCRgTrqkCUrWZefc5qQ5apUgEkp
         vADQarLeBvm+BaIOAf8KITRCj1TAbo8LcAdF+bxTRJQQsho4D/mT/sksa81oE8flmju5
         xH4lTv1fevqqW765jk941rjheBDMCuOsgBhRZ7zY1pBAV3YfRl2dEIH78cF7dgA71U4q
         2iu6W5IQT7d2UO+E6DlYXJj0J1KYxYW1eppgkG9Yme6A1t7lcmddNA0kfe/KSxrYwoEk
         OyRzDy2r1SrUyqYhr9pNvTkbsS4xl40SmuLHdraqT6RbdiUvQDtEC5a+31Vw1JuuTesp
         C8Rg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id;
        bh=80iUPmrcBk2+ug2egAEGLlkODFGV0leLCrkusgfj0dU=;
        b=KDPLkpUibPDqLm1bxntEtSkJoHpfnuv0iWJWdtB4ANUaB1Wg7Ic5uCc6EpPIEhsCww
         ltaZ31KDVUUWir5IyAOCvpgoQIJRWdYLIziMFrJwvXWGmfLxA9YzsuZJE6H9/4wokz4T
         cqFd7mMcHlMKUHrOAX9ImfyK/xMdamB0nXUQV9qfeYiHwT42E65D7A6xILyBMh4JqCZT
         4hQOiH9t2aomweSUqhQwhT5j0fD1eHerZT4FSv880zmw0zFB2tEJ8bmVcejCEFUfj+VS
         To/GXmxwlpBSx2K5wvwxXydiF3yFn0hQ9t+I++H74A/EJCWtwt4qAQ3KfdvBtoZcWLpa
         ElNg==
X-Gm-Message-State: APjAAAWiO6IGj+Jjc9tJjyC/eMQiCxU8nzYIvjw7W+CFXAYdvdUPXdm6
	p7g4N1TAsKddRY4oUAoJ0m0=
X-Google-Smtp-Source: APXvYqyJYSpyqwcn0d/MgjayTJ75Ym21bRNWYcLg1zdLL8TKqRLxUjPZ3mnh4+Ch6vIyIqg+t+OpXg==
X-Received: by 2002:a37:512:: with SMTP id 18mr15913097qkf.220.1566835623903;
        Mon, 26 Aug 2019 09:07:03 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::d081])
        by smtp.gmail.com with ESMTPSA id h1sm9711613qtc.92.2019.08.26.09.07.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Aug 2019 09:07:03 -0700 (PDT)
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
Subject: [PATCHSET v3] writeback, memcg: Implement foreign inode flushing
Date: Mon, 26 Aug 2019 09:06:51 -0700
Message-Id: <20190826160656.870307-1-tj@kernel.org>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Changes from v1[1]:

* More comments explaining the parameters.

* 0003-writeback-Separate-out-wb_get_lookup-from-wb_get_create.patch
  added and avoid spuriously creating missing wbs for foreign
  flushing.

Changes from v2[2]:

* Added livelock avoidance and applied other smaller changes suggested
  by Jan.

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
 0003-writeback-Separate-out-wb_get_lookup-from-wb_get_create.patch
 0004-writeback-memcg-Implement-cgroup_writeback_by_id.patch
 0005-writeback-memcg-Implement-foreign-dirty-flushing.patch

0001-0004 are prep patches which expose wb_completion and implement
bdi->id and flushing by bdi and memcg IDs.

0005 implements foreign inode flushing.

Thanks.  diffstat follows.

 fs/fs-writeback.c                |  130 ++++++++++++++++++++++++++++---------
 include/linux/backing-dev-defs.h |   23 ++++++
 include/linux/backing-dev.h      |    5 +
 include/linux/memcontrol.h       |   39 +++++++++++
 include/linux/writeback.h        |    2 
 mm/backing-dev.c                 |  120 +++++++++++++++++++++++++++++-----
 mm/memcontrol.c                  |  134 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |    4 +
 8 files changed, 404 insertions(+), 53 deletions(-)

--
tejun

[1] http://lkml.kernel.org/r/20190803140155.181190-1-tj@kernel.org
[2] http://lkml.kenrel.org/r/20190815195619.GA2263813@devbig004.ftw2.facebook.com



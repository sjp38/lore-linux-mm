Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61EE6C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:56:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12B872084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:56:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IV591KQo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12B872084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B56D56B0275; Thu, 15 Aug 2019 15:56:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B07786B0277; Thu, 15 Aug 2019 15:56:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6C26B027A; Thu, 15 Aug 2019 15:56:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0083.hostedemail.com [216.40.44.83])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1A06B0275
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:56:23 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3926D8248ABD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:56:23 +0000 (UTC)
X-FDA: 75825719046.11.title04_8f01da5fd3243
X-HE-Tag: title04_8f01da5fd3243
X-Filterd-Recvd-Size: 5538
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:56:22 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id s14so2895435qkm.4
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:56:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=8z1El4joEJPfZv/LOFE6htKfEd+io5Oqo8kE5bpDZI8=;
        b=IV591KQoCqfTve5OPjwQ47qHrWwJRQf3xrEvs5BOJAkNcxSizdrKC6TUcjcAaz9PoQ
         px/g/rn3BTUn77UIp7bkv6L/1d9qTjvMhw/OQX8nroblfWcmVo93BMhaqjBRFoBlA1RI
         10S1uDqFaHcg1R8CS7xKdqNFnQrkMfSNbLm4P9cBlbgE6j91TZWgHEUnVYF9rHSpnhuW
         tpDQZcemdcad6WXNjgVDo9e+re3W/IsVX5KPyDXUnuJvt8FOYQOOy8yprthlx9FQfKP2
         WjO9IZw+8e0pI6aAhBHhlJ2AmcWyozZKtW9efPWWbwtSQ+6Ecj79f0juQPYo17z08IuK
         FaFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mime-version:content-disposition:user-agent;
        bh=8z1El4joEJPfZv/LOFE6htKfEd+io5Oqo8kE5bpDZI8=;
        b=ZsNHh97Fo47gmX8dorG6jBtzHJm3zB68fDwqK3RPG12WNwyfy2vUI1YCxhBV2M2b8n
         hlp2tx1CFgy5uhuhHrR9PyVu/2so5lYrKZWUp8LshctQBMJLd16oUb+vzDa+ms71AJGa
         wvVLBVxuJhfCtRwtu2CFwXHKG3nkJ5gmX++sfCBKMGIybG3XKxfo7ym71fhJLDI0grNC
         g7E9jUlf/RUfB9vVCpTKa23R+Ph1/WX+2G60V149PnYPkndNEBVYHFAj9czmf8dIcDUy
         9xNWkeU7SDb3RjL7Mtx8p1zKHV7MT9DowqZ7mos/i6C1IK2VYLJMICwcIjEyqNvYzRr+
         cKMw==
X-Gm-Message-State: APjAAAV5owNYIeSP4pPuzoHLMYN7E5fMig5leutLc8PIO4os1+v7d2EO
	c41sch2SijdSmgB0S/MZes2bhK7/
X-Google-Smtp-Source: APXvYqyFEhAOKMzIeJih4yO72MRxGcpcdDYyJTV1V8osLQRoZK31+m6+Tv7/N0fkfX3fOJV0l5MUVQ==
X-Received: by 2002:a37:4791:: with SMTP id u139mr5430488qka.386.1565898981989;
        Thu, 15 Aug 2019 12:56:21 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:25cd])
        by smtp.gmail.com with ESMTPSA id c13sm1817004qtn.77.2019.08.15.12.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 12:56:21 -0700 (PDT)
Date: Thu, 15 Aug 2019 12:56:19 -0700
From: Tejun Heo <tj@kernel.org>
To: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, guro@fb.com, akpm@linux-foundation.org
Subject: [PATCHSET v2] writeback, memcg: Implement foreign inode flushing
Message-ID: <20190815195619.GA2263813@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
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

 fs/fs-writeback.c                |  114 +++++++++++++++++++++++----------
 include/linux/backing-dev-defs.h |   23 ++++++
 include/linux/backing-dev.h      |    5 +
 include/linux/memcontrol.h       |   39 +++++++++++
 include/linux/writeback.h        |    2 
 mm/backing-dev.c                 |  120 +++++++++++++++++++++++++++++------
 mm/memcontrol.c                  |  132 +++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c              |    4 +
 8 files changed, 386 insertions(+), 53 deletions(-)

--
tejun

[1] http://lkml.kernel.org/r/20190803140155.181190-1-tj@kernel.org


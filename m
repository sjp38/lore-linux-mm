Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01A1EC282DD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 904E720870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 08:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 904E720870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A5886B0005; Mon,  8 Apr 2019 04:27:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0552D6B0006; Mon,  8 Apr 2019 04:27:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E37106B0008; Mon,  8 Apr 2019 04:27:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF3CC6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 04:27:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t14so1532245edw.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 01:27:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=gRgsIXCq+3M6IilFW88nt5FFdJZtapSmS2Pt+14xoA8=;
        b=jIgVRB/fqjh/u2g7/bpJDxKC5nDobryoZbEt93drJUiraP5fHgjcmiVMfOW8iz0pcW
         ineZ1gGO44OffoKNT2cpUD6lHm+i+CVPUYa6tfJfVEoDZDyvJ8m2sPFaDIDq04RJFCwy
         7YVcbZyr9AApMsdHdYAvxPxUSMjKa6vY4LoKc7nFXapkERA004QE8uSPaqS/mg2Bn6cC
         t6/kb6JQsUu2Uk+qLyUy8cCx39GdRU710vp/RBBxGzccNze7b7NavP1mMHGo3HrGdk82
         iG1zCM05CIF51LvCPzctnxuTHgV6BJGa38Y9xPbnqf5zQuRKuLFWGqfBxONOfvkiqHjF
         l+wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUFwZOYJF8drQv7yFpvq2Hlf/6qHNy66oxO+TxSa38Htgrpoxi0
	rWo3qMmGyc60W43PhEke6RdrSyTBCDP/4HCE2erUNzYXrg7l8+KBi8XZ2NgEYWwLS5P9pSrrqiJ
	6MD6sU+pDO7HSzOM1onGEgdL9j5eaQkSYIrsgGJCkWiaXy8RWwkl9Wfq5jcN/gUi8kw==
X-Received: by 2002:a17:906:5855:: with SMTP id h21mr15629519ejs.264.1554712022060;
        Mon, 08 Apr 2019 01:27:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1y6kryYwR/dUWL/f0qoncBgbLzn8GgggD7iePlBETTG1xeXibeYnm5gejoZU2mwgyOH1m
X-Received: by 2002:a17:906:5855:: with SMTP id h21mr15629476ejs.264.1554712020984;
        Mon, 08 Apr 2019 01:27:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554712020; cv=none;
        d=google.com; s=arc-20160816;
        b=b0kbJNfCPLvmTRcvAl2HwHj3FjoyqkAL87ycucoQ+T/BjZdhp9athFVY0C5pDUozQx
         d0Dv8bPYvSPeRjlTlwTZi8386mnfi2gL/QkLy7bkXBcdjfd3kXGlsc8ejnf4sde7GdYt
         vBnep86cKaN2s+qoyFryD/zGy7TJNKj5m8RKk229HV1/TWpHjHXL8LCO9Yg0hGiNx1CI
         8rn9s4qrj4uWXuAoZ3i1PqY7P9AcxOoQWZ/uAUwyUCd/dH93yws5Cp1oWter6d1uD1vb
         gN8e0TukUhPKa2zyKkseDp9hfs+Zvn6dI4PF4nYN7iJ5eOpPFE35XT8IKXwACkD6S2OJ
         aeiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=gRgsIXCq+3M6IilFW88nt5FFdJZtapSmS2Pt+14xoA8=;
        b=Yh4CzkVl8tSp2opyg6zPzF72iZDKBxjzgJEVmx+bYauOGdCtqT7V1bdTXVNLeqwWu7
         nl8zeYkZoEIWLGBc/dBPvysGV8/n/v+ctKNt2MCHdhZz+SedvPm7jfinH+Uu8TmslHGf
         D5X3sUzVMvXwYQn+aShPhTSU901fw1wDbSLscBARVB+9LF7WDkKbXzSTLVu0b2DEj71C
         AfDHnbfS5AuQI4DJ33veZW3pVfexVt5MulXApAN5BqCJ/nbkMWC7Xql3W5firNYDMvI8
         5tT/kAFs5bUNjUHcKpgEFClUO5l7yyWwBXPHS6Al1sd/Bgj/05I3sqSgk36px0k4zkjW
         2iUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id x22si456166eda.329.2019.04.08.01.27.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 01:27:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 08 Apr 2019 10:27:00 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 08 Apr 2019 09:26:45 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 0/2] Preparing memhotplug for allocating memmap from hot-added range
Date: Mon,  8 Apr 2019 10:26:31 +0200
Message-Id: <20190408082633.2864-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v1 -> v2: Added David's feedback and his Reviewed-by

Hi,

these patches were posted as part of patchset [1], but it was agreed that
patch#3 must be further discussed.
Whole discussion can be seen in the cover letter.

But the first two patches make sense by themselves, as the first one is a nice
code cleanup, and the second one sets up the interface that the feature implemented
in [1] will use.

We decided to go this way because there are other people working on the same area,
and conflicts can arise easily, so better merge it now.
Also, it is safe as they do not implement any functional changes.

[1] https://patchwork.kernel.org/cover/10875017/

Michal Hocko (2):
  mm, memory_hotplug: cleanup memory offline path
  mm, memory_hotplug: provide a more generic restrictions for memory
    hotplug

 arch/arm64/mm/mmu.c            |  6 ++---
 arch/ia64/mm/init.c            |  6 ++---
 arch/powerpc/mm/mem.c          |  6 ++---
 arch/s390/mm/init.c            |  6 ++---
 arch/sh/mm/init.c              |  6 ++---
 arch/x86/mm/init_32.c          |  6 ++---
 arch/x86/mm/init_64.c          | 10 ++++----
 include/linux/memory_hotplug.h | 32 ++++++++++++++++++------
 kernel/memremap.c              | 12 ++++++---
 mm/memory_hotplug.c            | 56 ++++++++++++++----------------------------
 mm/page_alloc.c                | 11 +++++++--
 11 files changed, 84 insertions(+), 73 deletions(-)

-- 
2.13.7


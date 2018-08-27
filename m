Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 67A356B4037
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:26:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w44-v6so6520155edb.16
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:26:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t22-v6sor6365865edi.11.2018.08.27.04.26.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 04:26:36 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] mmu_notifiers follow ups
Date: Mon, 27 Aug 2018 13:26:20 +0200
Message-Id: <20180827112623.8992-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
Tetsuo has noticed some fallouts from 93065ac753e4 ("mm, oom:
distinguish blockable mode for mmu notifiers"). One of them has
been fixed and picked up by AMD/DRM maintainer [1]. XEN issue is
fixed by patch 1. I have also clarified expectations about blockable
semantic of invalidate_range_end. Finally the last patch removes
MMU_INVALIDATE_DOES_NOT_BLOCK which is no longer used nor needed.

[1] http://lkml.kernel.org/r/20180824135257.GU29735@dhcp22.suse.cz

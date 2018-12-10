Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 907F98E0001
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 05:36:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so3974812edm.20
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 02:36:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21-v6sor2892988ejx.10.2018.12.10.02.36.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 02:36:48 -0800 (PST)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 0/4] mmu notifier debug checks v2
Date: Mon, 10 Dec 2018 11:36:37 +0100
Message-Id: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@ffwll.ch>

Hi all,

Here's v2 of my mmu notifier debug checks.

I think the last two patches could probably be extended to all callbacks,
but I'm not really clear on the exact rules. But happy to extend them if
there's interest.

This stuff helps us catch issues in the i915 mmu notifier implementation.

Thanks, Daniel

Daniel Vetter (4):
  mm: Check if mmu notifier callbacks are allowed to fail
  kernel.h: Add non_block_start/end()
  mm, notifier: Catch sleeping/blocking for !blockable
  mm, notifier: Add a lockdep map for invalidate_range_start

 include/linux/kernel.h       | 10 +++++++++-
 include/linux/mmu_notifier.h |  6 ++++++
 include/linux/sched.h        |  4 ++++
 kernel/sched/core.c          |  6 +++---
 mm/mmu_notifier.c            | 18 +++++++++++++++++-
 5 files changed, 39 insertions(+), 5 deletions(-)

-- 
2.20.0.rc1

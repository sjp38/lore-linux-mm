Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7B66B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:44:00 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id k10-v6so6636094ljc.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:44:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t30-v6sor6261386ljd.8.2018.10.16.10.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 10:43:57 -0700 (PDT)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH 0/2] shmem, drm/i915: Mark pinned shmemfs pages as unevictable
Date: Wed, 17 Oct 2018 01:42:58 +0800
Message-Id: <20181016174300.197906-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org
Cc: mhocko@suse.com, akpm@linux-foundation.org, chris@chris-wilson.co.uk, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org, Kuo-Hsin Yang <vovoy@chromium.org>

When a graphics heavy application is running, i915 driver may pin a lot
of shmemfs pages and vmscan slows down significantly by scanning these
pinned pages. This patch is an alternative to the patch by Chris Wilson
[1]. As i915 driver pins all pages in an address space, marking an
address space as unevictable is sufficient to solve this issue.

[1]: https://patchwork.kernel.org/patch/9768741/

Kuo-Hsin Yang (2):
  shmem: export shmem_unlock_mapping
  drm/i915: Mark pinned shmemfs pages as unevictable

 Documentation/vm/unevictable-lru.rst | 4 +++-
 drivers/gpu/drm/i915/i915_gem.c      | 8 ++++++++
 mm/shmem.c                           | 2 ++
 3 files changed, 13 insertions(+), 1 deletion(-)

-- 
2.19.1.331.ge82ca0e54c-goog

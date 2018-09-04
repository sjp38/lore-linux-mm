Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE4D6B6EE8
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 14:33:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so2179304pgq.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 11:33:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o127-v6sor4823173pga.195.2018.09.04.11.33.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Sep 2018 11:33:39 -0700 (PDT)
Subject: [PATCH 0/2] Address issues slowing memory init
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 04 Sep 2018 11:33:32 -0700
Message-ID: <20180904181550.4416.50701.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patch series is meant to address some issues I consider to be
low-hanging fruit in regards to memory initialization optimization.

With these two changes I am able to cut the hot-plug memory initialization
times in my environment in half.

---

Alexander Duyck (2):
      mm: Move page struct poisoning from CONFIG_DEBUG_VM to CONFIG_DEBUG_VM_PGFLAGS
      mm: Create non-atomic version of SetPageReserved for init use


 include/linux/page-flags.h |    1 +
 mm/memblock.c              |    2 +-
 mm/page_alloc.c            |    4 ++--
 mm/sparse.c                |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

--

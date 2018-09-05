Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9C9F6B752C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:13:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bg5-v6so4364219plb.20
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:13:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d29-v6sor698505pfj.97.2018.09.05.14.13.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 14:13:23 -0700 (PDT)
Subject: [PATCH v2 0/2] Address issues slowing memory init
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 05 Sep 2018 14:13:22 -0700
Message-ID: <20180905211041.3286.19083.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, dave.hansen@intel.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patch series is meant to address some issues I consider to be
low-hanging fruit in regards to memory initialization optimization.

With these two changes I am able to cut the hot-plug memory initialization
times in my environment in half.

v2: Added comments about why we are using __SetPageReserved
    Added new config and updated approach used for page init poisoning

---

Alexander Duyck (2):
      mm: Move page struct poisoning to CONFIG_DEBUG_VM_PAGE_INIT_POISON
      mm: Create non-atomic version of SetPageReserved for init use


 include/linux/page-flags.h |    9 +++++++++
 lib/Kconfig.debug          |   14 ++++++++++++++
 mm/memblock.c              |    5 ++---
 mm/page_alloc.c            |   13 +++++++++++--
 mm/sparse.c                |    4 +---
 5 files changed, 37 insertions(+), 8 deletions(-)

--

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1CFC6B312C
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 15:25:53 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e88-v6so8958583qtb.1
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 12:25:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x26-v6si2808812qtj.366.2018.08.24.12.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 12:25:52 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 0/7] HMM updates, improvements and fixes
Date: Fri, 24 Aug 2018 15:25:42 -0400
Message-Id: <20180824192549.30844-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Few fixes that only affect HMM users. Improve the synchronization call
back so that we match was other mmu_notifier listener do and add proper
support to the new blockable flags in the process.

For curious folks here are branches to leverage HMM in various existing
device drivers:

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau-v01
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-radeon-v00
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-intel-v00

More to come (amd gpu, Mellanox, ...)

I expect more of the preparatory work for nouveau will be merge in 4.20
(like we have been doing since 4.16) and i will wait until this patchset
is upstream before pushing the patches that actualy make use of HMM (to
avoid complex tree inter-dependency).

JA(C)rA'me Glisse (5):
  mm/hmm: fix utf8 ...
  mm/hmm: properly handle migration pmd
  mm/hmm: use a structure for update callback parameters
  mm/hmm: invalidate device page table at start of invalidation
  mm/hmm: proper support for blockable mmu_notifier

Ralph Campbell (2):
  mm/rmap: map_pte() was not handling private ZONE_DEVICE page properly
  mm/hmm: fix race between hmm_mirror_unregister() and mmu_notifier
    callback

 include/linux/hmm.h  |  37 +++++++----
 mm/hmm.c             | 150 ++++++++++++++++++++++++++++++-------------
 mm/page_vma_mapped.c |   9 +++
 3 files changed, 142 insertions(+), 54 deletions(-)

-- 
2.17.1

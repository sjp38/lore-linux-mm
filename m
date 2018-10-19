Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC066B000A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:04:50 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w5-v6so1447776qto.18
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:04:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q125-v6si652584qkd.100.2018.10.19.09.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 09:04:49 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 0/6] HMM updates, improvements and fixes v2
Date: Fri, 19 Oct 2018 12:04:36 -0400
Message-Id: <20181019160442.18723-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

[Andrew this is for 4.20, stable fixes as cc to stable]

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

JA(C)rA'me Glisse (4):
  mm/hmm: fix utf8 ...
  mm/hmm: properly handle migration pmd v3
  mm/hmm: use a structure for update callback parameters v2
  mm/hmm: invalidate device page table at start of invalidation

Ralph Campbell (2):
  mm/rmap: map_pte() was not handling private ZONE_DEVICE page properly
    v3
  mm/hmm: fix race between hmm_mirror_unregister() and mmu_notifier
    callback

 include/linux/hmm.h  |  33 +++++++----
 mm/hmm.c             | 134 +++++++++++++++++++++++++++++--------------
 mm/page_vma_mapped.c |  24 +++++++-
 3 files changed, 137 insertions(+), 54 deletions(-)

-- 
2.17.2

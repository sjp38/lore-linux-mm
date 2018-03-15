Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D01CC6B0003
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 14:37:10 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l5so4990211qth.18
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:37:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 206si5231339qkn.24.2018.03.15.11.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 11:37:09 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 0/4] hmm: fixes and documentations
Date: Thu, 15 Mar 2018 14:36:56 -0400
Message-Id: <20180315183700.3843-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

All patches only impact HMM user, there is no implication outside HMM.

First patch improve documentation to better reflect what HMM is. Second
patch fix #if/#else placement in hmm.h. The third patch add a call on
mm release which helps device driver who use HMM to clean up early when
a process quit. Finaly last patch modify the CPU snapshot and page fault
helper to simplify device driver. The nouveau patchset i posted last
week already depends on all of those patches.

You can find them in a hmm-for-4.17 branch:

git://people.freedesktop.org/~glisse/linux
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-4.17

Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>

JA(C)rA'me Glisse (2):
  mm/hmm: fix header file if/else/endif maze
  mm/hmm: change CPU page table snapshot functions to simplify drivers

Ralph Campbell (2):
  mm/hmm: documentation editorial update to HMM documentation
  mm/hmm: HMM should have a callback before MM is destroyed

 Documentation/vm/hmm.txt | 360 ++++++++++++++++++++++++-----------------------
 MAINTAINERS              |   1 +
 include/linux/hmm.h      | 147 ++++++++++---------
 mm/hmm.c                 | 351 +++++++++++++++++++++++++--------------------
 4 files changed, 468 insertions(+), 391 deletions(-)

-- 
2.14.3

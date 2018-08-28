Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B33406B45E9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:20:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d132-v6so944938pgc.22
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:20:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b90-v6sor177440pfe.77.2018.08.28.04.20.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:20:45 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 0/3] mm: dirty/accessed pte optimisations
Date: Tue, 28 Aug 2018 21:20:31 +1000
Message-Id: <20180828112034.30875-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Here are some patches that didn't get much comment last time. It
looks like x86 might benefit too though, so that might get people
interested. 

I improved changelogs and added some comments, but no real logic
changes.

I hope I didn't get the x86 numbers wrong, they're more significant
than I expected so it could quite well be a problem with my test
(corrections welcome). Any data from other archs would be interesting
too.

Andrew perhaps if there aren't objections these could go in mm for
a while. 

Thanks,
Nick


Nicholas Piggin (3):
  mm/cow: don't bother write protectig already write-protected huge
    pages
  mm/cow: optimise pte dirty/accessed bits handling in fork
  mm: optimise pte dirty/accessed bit setting by demand based pte
    insertion

 mm/huge_memory.c | 24 +++++++++++++++---------
 mm/memory.c      | 18 ++++++++++--------
 mm/vmscan.c      |  8 ++++++++
 3 files changed, 33 insertions(+), 17 deletions(-)

-- 
2.18.0

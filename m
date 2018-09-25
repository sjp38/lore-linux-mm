Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0E6A8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:35:54 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 1-v6so9022191qtp.10
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:35:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4-v6sor869334qtn.44.2018.09.25.08.35.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:35:53 -0700 (PDT)
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: [PATCH v2 0/3] mm: Fix for movable_node boot option
Date: Tue, 25 Sep 2018 11:35:29 -0400
Message-Id: <20180925153532.6206-1-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org

This patch series are the fix for movable_node boot option
issue which was introduced by commit 124049decbb1 ("x86/e820:
put !E820_TYPE_RAM regions into memblock.reserved").

First patch, revert the commit. Second and third patch fix the
original issue.

Masayoshi Mizuma (1):
  Revert "x86/e820: put !E820_TYPE_RAM regions into memblock.reserved"

Naoya Horiguchi (1):
  mm: zero remaining unavailable struct pages

Pavel Tatashin (1):
  mm: return zero_resv_unavail optimization

 arch/x86/kernel/e820.c   | 15 +++--------
 include/linux/memblock.h | 15 -----------
 mm/page_alloc.c          | 54 +++++++++++++++++++++++++++-------------
 3 files changed, 40 insertions(+), 44 deletions(-)

-- 
2.18.0

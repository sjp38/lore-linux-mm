Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7FF6B000D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:38:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a130-v6so1857878qkb.7
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:38:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 145-v6sor2929623qkh.75.2018.10.02.07.38.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 07:38:29 -0700 (PDT)
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: [PATCH v3 0/3] mm: Fix for movable_node boot option
Date: Tue,  2 Oct 2018 10:38:18 -0400
Message-Id: <20181002143821.5112-1-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org

This patch series are the fix for movable_node boot option
issue which was introduced by commit 124049decbb1 ("x86/e820:
put !E820_TYPE_RAM regions into memblock.reserved").

The commit breaks the option because it changed the memory
gap range to reserved memblock. So, the node is marked as
Normal zone even if the SRAT has Hot pluggable affinity.

First and second patch fix the original issue which the commit
tried to fix, then revert the commit.

Changelog from v2:
 - Change the patch order. The revert patch is moved to the last.

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

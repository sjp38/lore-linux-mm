Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EAAD8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:07:49 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j8so4129072plb.1
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:07:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x8sor8342354plo.55.2018.12.14.10.07.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 10:07:48 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
Subject: [RFC 0/4] vmalloc enhancements
Date: Fri, 14 Dec 2018 10:07:16 -0800
Message-Id: <20181214180720.32040-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

The patchset contains few changes to the vmalloc code, which are
leading to some performance gains and code simplification.

Also, it exports a number of pages, used by vmalloc(),
in /proc/meminfo.

Patch (1) removes some redundancy on __vunmap().
Patch (2) is a preparation for patch (3).
Patch (3) merges independent 3 metadata allocations into one.
Patch (4) adds vmalloc counter to /proc/meminfo.

Roman Gushchin (4):
  mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
  mm: separate memory allocation and actual work in alloc_vmap_area()
  mm: allocate vmalloc metadata in one allocation
  mm: show number of vmalloc pages in /proc/meminfo

 arch/mips/mm/ioremap.c      |   7 +-
 arch/nios2/mm/ioremap.c     |   4 +-
 arch/sh/kernel/cpu/sh4/sq.c |   5 +-
 arch/sh/mm/ioremap.c        |   8 +-
 arch/x86/mm/ioremap.c       |   4 +-
 fs/proc/meminfo.c           |   2 +-
 include/linux/vmalloc.h     |   6 +-
 mm/vmalloc.c                | 206 ++++++++++++++++++++++--------------
 8 files changed, 140 insertions(+), 102 deletions(-)

-- 
2.19.2

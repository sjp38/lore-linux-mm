Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DBF796B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 12:07:26 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so7950150wiw.2
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 09:07:26 -0800 (PST)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com. [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id c6si6362658wix.107.2015.01.07.09.07.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 09:07:24 -0800 (PST)
Received: by mail-we0-f182.google.com with SMTP id w62so1539944wes.27
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 09:07:23 -0800 (PST)
From: Petr Cermak <petrcermak@chromium.org>
Subject: [PATCH v2 0/2] task_mmu: Add user-space support for resetting mm->hiwater_rss (peak RSS)
Date: Wed,  7 Jan 2015 17:06:52 +0000
Message-Id: <cover.1420643264.git.petrcermak@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>, Petr Cermak <petrcermak@chromium.org>

Being able to reset mm->hiwater_rss (resident set size high water mark) from
user space would enable fine grained iterative memory profiling. I propose a
very short patch for doing so.

The driving use-case for this would be getting the peak RSS value, which can be
retrieved from the VmHWM field in /proc/pid/status, per benchmark iteration or
test scenario.

Changelog:

v2:
- clarify behaviour in documentation as suggesed by Andrew Morton
<akpm@linux-foundation.org>
- fix a declaration-after-statement warning in fs/proc/task_mmu.c

v1: https://lkml.org/lkml/2014/12/10/312

Petr Cermak (2):
task_mmu: Reduce excessive indentation in clear_refs_write
task_mmu: Add user-space support for resetting mm->hiwater_rss (peak RSS)

 Documentation/filesystems/proc.txt |   3 +
 fs/proc/task_mmu.c                 | 115 +++++++++++++++++++++----------------
 include/linux/mm.h                 |   5 ++
 3 files changed, 74 insertions(+), 49 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

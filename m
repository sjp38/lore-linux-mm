Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CD8136B0005
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 11:18:45 -0500 (EST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 0/2] Arch-specific user pgtables ceiling
Date: Mon, 18 Feb 2013 16:18:29 +0000
Message-Id: <1361204311-14127-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

Following feedback on the previous patch to limit the free_pgtables()
ceiling, this series introduces a USER_PGTABLES_CEILING macro defaulting
to 0 and an ARM-specific definition to TASK_SIZE.

Catalin Marinas (1):
  arm: Set the page table freeing ceiling to TASK_SIZE

Hugh Dickins (1):
  mm: Allow arch code to control the user page table ceiling

 arch/arm/include/asm/pgtable.h |  7 +++++++
 fs/exec.c                      |  4 ++--
 include/asm-generic/pgtable.h  | 10 ++++++++++
 mm/mmap.c                      |  4 ++--
 4 files changed, 21 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
